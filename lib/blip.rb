require "blip/version"
require "blip/server"
require "blip/connection"
require "blip/request"
require "blip/headers"
require "blip/builder"
require "blip/response"
require "blip/http_status"

module Blip
  CHUNK_SIZE = 16 * 1024

  class Error < StandardError; end
  # Your code goes here...
end

app = Blip::Builder.parse_file("app/config.ru")

Blip::Server.new(3001, app).start 2
