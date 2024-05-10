# Load libraries
require "yaml"

# Custom libraries
require "./lib/worker.rb"
require "./module/worker-log.rb"
require "./lib/opt-parser.rb"

begin
  # Parse options
  options = OptParser.parse

  # Create worker
  worker = Worker.new(options)
  # Start worker
  worker.start_worker()
end
