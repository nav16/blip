require "blip/version"
require "blip/server"
require "blip/connection"
require "blip/request"

module Blip
  CHUNK_SIZE = 16 * 1024

  class Error < StandardError; end
  # Your code goes here...
end

Blip::Server.new.run
