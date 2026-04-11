module Blip
  class Headers
    attr_accessor :env

    def initialize(parser, env)
      @parser = parser
      @env = env
    end

    def parse!
      @parser.headers.each_pair do |name, value|
        env["HTTP_#{name.upcase.tr('-', '_')}"] = value
      end

      path, query = @parser.request_url.split("?", 2)

      env["REQUEST_URI"]    = @parser.request_url
      env["REQUEST_PATH"]   = path
      env["PATH_INFO"]      = path
      env["QUERY_STRING"]   = query || ""
      env["SCRIPT_NAME"]    = ""
      env["REQUEST_METHOD"] = @parser.http_method

      host, port = (env["HTTP_HOST"] || "").split(":", 2)
      env["SERVER_NAME"] = host || "localhost"
      env["SERVER_PORT"] = port || "80"

      env["rack.version"]      = [1, 3]
      env["rack.url_scheme"]   = "http"
      env["rack.input"]        = StringIO.new("").tap { |io| io.set_encoding("ASCII-8BIT") }
      env["rack.errors"]       = $stderr
      env["rack.multithread"]  = false
      env["rack.multiprocess"] = true
      env["rack.run_once"]     = false

      env
    end
  end
end
