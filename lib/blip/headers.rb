module Blip
  class Headers
    attr_accessor :env

    def initialize(parser, env)
      @parser = parser
      @env = env
    end

    def parse!
      @parser.headers.each_pair do |name, value|
        name = "HTTP_#{name.upcase.tr('-', '_')}"
        env[name] = value
      end
      env["REQUEST_URI"]    = @parser.request_url
      env["REQUEST_PATH"]   = @parser.request_url
      env["PATH_INFO"]      = @parser.request_url
      env["REQUEST_METHOD"] = @parser.http_method
    end
  end
end
