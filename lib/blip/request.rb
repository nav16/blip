require "http/parser"

module Blip
  class Request
    attr_accessor :parser, :parsed

    def initialize
      @parser = Http::Parser.new(self)
      @parsed = false
    end

    def on_message_complete
      puts "#{parser.http_method} #{parser.request_url}"
      puts "  " + parser.headers.inspect
      puts

      parsed!
    end

    private

    def parsed!
      @parsed = true
    end
  end
end
