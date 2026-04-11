module Blip
  class InvalidRequest < StandardError; end

  class Request
    attr_accessor :parser, :parsed, :env

    def initialize(env)
      @env = env
      @parser = Http::Parser.new(self)
      @parsed = false
      @body = StringIO.new.tap { |io| io.set_encoding("ASCII-8BIT") }
    end

    def on_body(chunk)
      @body << chunk
    end

    def on_message_complete
      @verb = parser.http_method.upcase
      @path = parser.request_url
      parsed!
    end

    def parse!
      headers!
      @body.rewind
      @env["rack.input"] = @body
    end

    private

    def parsed!
      @parsed = true
    end

    def headers!
      Headers.new(parser, env).parse!
    end
  end
end
