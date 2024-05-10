# Load libraries
require "optparse"

# Custom libraries
require "./module/worker-log.rb"

##
# @class OptParser
# Class parsing command-line options
#
class OptParser
  ##
  # Parses command-line options
  #
  # @return [Hash] A hash containing options
  #
  # @raise [OptionParser::InvalidOption] if an unknown option is provided.
  # @raise [OptionParser::MissingArgument] if the mode option is missing.
  #
  def self.parse
    options = { mode: nil }

    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby-worker.rb [options]"

      # Options for worker mode
      opts.on("-m", "--mode MODE", String, "Set operation mode") do |m|
        options[:mode] = m
      end

      # Enable debug
      opts.on("-d", "--debug", "Show debug logs") do
        WorkerLog.logger_level = Logger::DEBUG
      end

      # Help message
      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    # Starts parser
    begin
      parser.parse!

      # Check if 'mode' argument is present
      unless options[:mode]
        raise OptionParser::MissingArgument, "Mode is required"
      end

      # Rescue error for invalid option and missing argument
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      WorkerLog.log.error e.message
      WorkerLog.log.error parser
      exit
    end
    options
  end
end
