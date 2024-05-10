# AWS related libraries
require "aws-sdk-s3"

##
# @class S3TransferManager
# Class handling downloading and uploading files from AWS SQS
#
class S3TransferManager
  ##
  # Sets up the AWS S3 client and configurations.
  #
  def initialize
    @client = Aws::S3::Client.new()

    WorkerLog.log.debug "S3TransferManager initialized"
  end

  ##
  # Downloads a file from the AWS S3 bucket
  #
  # @param [String] bucket The AWS S3 bucket name.
  # @param [String] key The AWS S3 bucket object key.
  # @param [String] target The download target file.
  #
  # @return [Aws::S3::Types::GetObjectOutput]
  #
  # @raise [Aws::S3::Errors::ServiceError] If an error occurs during getting object.
  #
  # TODO:
  # - fail-safe system
  def download_file(bucket, key, target)
    resp = @client.get_object({
      bucket: bucket,
      key: key,
      response_target: target,
    })

    resp
  rescue Aws::S3::Errors::ServiceError => e
    WorkerLog.log.error "Error downloading files: #{e}"
  end

  ##
  # Uploads a file to the AWS S3 bucket
  #
  # @param [String] bucket The AWS S3 bucket name.
  # @param [String] source The source upload file.
  # @param [String] key The AWS S3 bucket object key.
  #
  # @return [Aws::S3::Types::PutObjectOutput]
  #
  # TODO:
  # - fail-safe system
  def upload_file(bucket, source, key)
    resp = nil
    File.open(source, "rb") do |file|
      resp = @client.put_object(bucket: bucket, key: key, body: file)
    end

    resp
  rescue Aws::S3::Errors::ServiceError => e
    WorkerLog.log.error "Error uploading files: #{e}"
  end
end
