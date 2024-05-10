require "./module/app-config.rb"
require "./module/worker-log.rb"

class JobProcessor
  def initialize(mode, job)
    @mode = mode
    @job = job
    WorkerLog.log.info "(ID: #{job.id}) JobProcessor created."
  end

  ##
  # Return if current component is executable by worker
  #
  # @return [Boolean] Check result
  #
  def task_executable? = AppConfig.components[@job.component] == @mode

  ##
  # Execute current component file
  #
  # @return [String] Execution result
  #
  def execute_component
    component = @job.component
    WorkerLog.log.info "(ID: #{@job.id}) Starting #{component} execution"
    result = `python3 components/#{component}.py #{@job.work_dir} #{@job.data.name}`
    WorkerLog.log.debug "(ID: #{@job.id}) #{component} result: #{result}"
    WorkerLog.log.info "(ID: #{@job.id}) Ended #{component} execution"

    result
  end
end
