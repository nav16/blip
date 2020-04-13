require "http/parser"

module Blip
  class InvalidRequest < StandardError; end

  class Request
    attr_accessor :parser, :parsed, :env

    def initialize(env)
      @env = env
      @parser = Http::Parser.new(self)
      @parsed = false
    end

    def on_message_complete
      puts "#{parser.http_method} #{parser.request_url}"
      puts "  " + parser.headers.inspect
      puts

      @verb = parser.http_method.upcase
      @path = parser.request_url
      parsed!
    end

    def parse!
      headers!
    end

    private

    def parsed!
      @parsed = true
    end

    def headers!
      headers = Headers.new(parser, env)
      @headers = headers.parse!
      env = headers.env
    end
  end
end
