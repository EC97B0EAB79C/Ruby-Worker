# Custom libraries
require "./lib/aws-managers/s3-transfer-manager.rb"
require "./lib/aws-managers/sqs-message-manager.rb"
require "./module/app-config.rb"
require "./module/worker-log.rb"

# Other libraries
require "fileutils"

##
# @class Worker
# @brief Worker class to process jobs from messages.
#
class Worker
  ##
  # Initializes the Worker.
  # @param [Hash] options The configuration options for worker setup.
  #
  def initialize(options)
    @mode = options[:mode]
    @receive_url = AppConfig.sqs_url[@mode]

    @transfer_manager = S3TransferManager.new()
    @message_manager = SQSMessageManager.new(@receive_url)
  end

  ##
  # Starts the worker loop to continuously receive and process job messages.
  #
  def start_worker
    WorkerLog.log.info "===== Starting '#{@mode}' worker ====="
    loop do
      # receive message
      message = @message_manager.receive_message
      next if message.nil?
      WorkerLog.log.info "Received message: #{message.message_id}"

      # process message
      result = process_message(message.body)
      if !result.nil?
        WorkerLog.log.info "Successfully processed message: #{message.message_id}"
      else
        WorkerLog.log.info "Failed to process message: #{message.message_id}"
      end

      # Delete message from queue
      @message_manager.delete_message(message.receipt_handle)
      WorkerLog.log.info "Deleted message: #{message.message_id}"
    end
  end

  ##
  # Processes a single message received from SQS.
  #
  # @param [Aws::SQS::Types::Message] message The message object to be processed.
  #
  # @return [String, nil] Return data name for latest executed task
  #
  def process_message(message)
    # Hash message
    message_hash = YAML.safe_load(message)
    # Job and processor variables
    job = Job.new(message_hash)
    processor = JobProcessor.new(@mode, job)

    # Download data to process
    download_data(job)

    # Run task while available
    while !job.finished?
      WorkerLog.log.info "(ID: #{job.id}) Processing task #{job.current_task}"

      # Check if worker can execute task
      if !processor.task_executable?
        # Delegate to another worker if task is unexecutable
        delegate_job(job)
        break
      end

      # Execute task
      result_data = processor.execute_component
      break if result_data.nil?

      # Upload result data
      upload_data(job, result_data)

      job.next_task
    end

    result_data
  end

  ##
  # Delegate job to other workers
  #
  # @param [Job] job
  # @param [Aws::SQS::Types::Message] message
  #
  def delegate_job(job)
    delegate_to = AppConfig.components[job.component]
    WorkerLog.log.debug "(ID: #{job.id}) Sending job to #{delegate_to} worker"
    @message_manager.send_message(
      AppConfig.sqs_url[delegate_to],
      job.delegate_message,
      job.id,
      job.deduplication
    )
  end

  ##
  # Download data to process
  #
  # @param [Job] job
  #
  def download_data(job)
    WorkerLog.log.debug "(ID: #{job.id}) Downloading work data"

    FileUtils.mkdir_p job.work_dir

    @transfer_manager.download_file(
      "",
      job.download_key,
      job.work_dir + job.target_data
    )
    WorkerLog.log.debug "(ID: #{job.id}) Downloaded work data"
  end

  ##
  # Upload processed data
  #
  # @param [Job] job
  # @param [String] result_data The location of processed data
  #
  def upload_data(job, result_data)
    WorkerLog.log.debug "(ID: #{job.id}) Uploading work data for task #{job.current_task}"

    @transfer_manager.upload_file(
      "",
      result_data,
      job.upload_key
    )
  end
end
