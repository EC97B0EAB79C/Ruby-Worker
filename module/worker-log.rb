# Load libraries
require "logger"

##
# @module WorkerLog
# Module for singleton logger instance.
#
module WorkerLog
  @logger_level = Logger::INFO

  ##
  # Sets the logging level for the logger.
  #
  # @param [Integer] level The log level.
  #
  def self.logger_level=(level)
    @logger_level = level
  end

  ##
  # Provides access to the logger instance. Initializes the logger if it has not been created.
  #
  # @return [Logger] The Logger instance.
  #
  def self.log
    if @logger.nil?
      @logger = Logger.new STDOUT
      @logger.level = @logger_level
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S "
    end
    @logger
  end
end
