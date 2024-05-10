# Custom libraries
require "./data/data.rb"
require "./module/app-config.rb"
require "./module/worker-log.rb"

class Job
  attr_reader :id, :current_task, :data

  def initialize(message_hash)
    # Job Variables
    @message_hash = message_hash
    @job = @message_hash["job"]
    @id = @job["id"]
    @current_task = @job["current_task"]
    @total_task = @job["total_task"]

    # Data Variables
    @data = Data.new(@job["data"])

    # Task Variables
    @tasks = @message_hash["tasks"]

    WorkerLog.log.debug "(ID: #{@id}) Job instance created."
  end

  # Job variables
  def next_task
    @current_task += 1
  end

  def finished? = @current_task == @total_task
  def task = @tasks["task#{current_task}"]
  def component = task.keys.first

  # Data file variables
  def work_dir = "workspace/#{@id}"
  def download_bucket = @current_task.zero? ? AppConfig.bucket["data"] : AppConfig.bucket["job"]
  def upload_bucket = AppConfig.bucket["job"]
  def download_key = "#{@current_task.zero? ? @data.id : @id}/#{target_data}"
  def upload_key = "#{@id}/#{result_data}"
  def target_data = "#{@data.name}#{@current_task.zero? ? ".#{@data.type}" : "-task#{@current_task}"}"
  def result_data = "#{@data.name}#{@current_task == @total_task - 1 ? "-final" : "-task#{@current_task + 1}"}"

  def delegate_message
    @message_hash["job"]["current_task"] = @current_task
    YAML.dump(@message_hash)
  end

  def deduplication = "#{@id}-#{@current_task}"
end
