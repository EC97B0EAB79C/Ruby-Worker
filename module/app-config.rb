# Load libraries
require "yaml"

##
# @module AppConfig
# Loads configuration from a YAML file
#
module AppConfig
  @config = nil

  ##
  # Loads the application configuration from a YAML file if not already loaded.
  #
  # @return [Hash] The loaded configuration as a hash.
  #
  def self.load_config
    @config ||= YAML.load_file("./config/config.yml")
  end

  ##
  # Retrieves the SQS URL hash from the application configuration.
  #
  # @return [hash] The SQS URL hash from the config YAML file.
  #
  def self.sqs_url
    load_config["sqs_url"]
  end

  ##
  # Retrieves the components hash from the application configuration.
  #
  # @return [hash] The components hash from the config YAML file.
  #
  def self.components
    load_config["components"]
  end
end
