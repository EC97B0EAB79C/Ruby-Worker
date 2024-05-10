# AWS related libraries
require "aws-sdk-sqs"

# Custom libraries
require "./lib/worker-log.rb"

##
# @class SQSMessageManager
# Class handling receiving, deleting, sending message from AWS SQS
#
class SQSMessageManager
  ##
  # Sets up the AWS SQS client and configurations.
  #
  # @param [String] receive_url The URL of the AWS SQS queue to interact with.
  #
  def initialize(receive_url)
    @client = Aws::SQS::Client.new()
    @receive_url = receive_url
    @wait_time = 10

    WorkerLog.log.debug "SQSMessageManager initialized"
  end

  ##
  # Receives a message from the AWS SQS queue.
  #
  # @return [Aws::SQS::Types::Message, nil] The received message or nil if no message is available.
  #
  # @raise [Aws::SQS::Errors::ServiceError] If an error occurs during the fetch from SQS.
  #
  def receive_message
    message = nil
    resp = @client.receive_message(
      queue_url: @receive_url,
      wait_time_seconds: @wait_time,
    )
    resp.messages.each do |m|
      message = m
    end
    message
  rescue Aws::SQS::Errors::ServiceError => e
    WorkerLog.log.error "Error fetching messages: #{e}"
  end

  ##
  # Deletes a message from the AWS SQS queue using the message's receipt handle.
  #
  # @param [String] receipt_handle The receipt handle of the message to be deleted.
  #
  # @raise [Aws::SQS::Errors::ServiceError] If an error occurs during the deletion from SQS.
  #
  def delete_message(receipt_handle)
    @client.delete_message({
      queue_url: @receive_url,
      receipt_handle: receipt_handle,
    })
  rescue Aws::SQS::Errors::ServiceError => e
    WorkerLog.log.error "Error deleting messages: #{e}"
  end

  ##
  # Sends a message to an AWS SQS queue specified by the URL.
  #
  # @param [String] url The URL of the SQS queue where the message will be sent.
  # @param [String] message The body of the message to send.
  # @param [String] id The message group ID.
  # @param [String] deduplication The deduplication ID.
  #
  # @raise [Aws::SQS::Errors::ServiceError] If an error occurs during the sending of the message.
  #
  def send_message(url, message, id, deduplication)
    resp = @client.send_message({
      queue_url: url,
      message_body: message,
      message_group_id: id.ljust(128, "0"),
      message_deduplication_id: deduplication,
    })
  rescue Aws::SQS::Errors::ServiceError => e
    WorkerLog.log.error "Error sending messages: #{e}"
  end
end
