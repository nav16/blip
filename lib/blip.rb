require "socket"
require "http/parser"
require "stringio"

require "blip/version"
require "blip/builder"
require "blip/http_status"

module Blip
  CHUNK_SIZE = 16 * 1024

  class Error < StandardError; end

  autoload :Connection,         "blip/connection"
  autoload :Headers,            "blip/headers"
  autoload :Request,            "blip/request"
  autoload :Response,           "blip/response"
  autoload :Server,             "blip/server"
end

app = Blip::Builder.parse_file("app/config.ru")

Blip::Server.new(3001, app).start 2
