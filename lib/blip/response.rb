module Blip
  # A response sent to the client.
  class Response
    attr_accessor :status
    attr_reader :body, :headers

    REASONS = {
      200 => "OK",
      404 => "Not Found"
    }.freeze

    HEADER_FORMAT  = "%s: %s\r\n".freeze

    def initialize
      @headers = {}
      @body    = StringIO.new
      @status  = 200
    end

    def headers_output
      @headers["Content-Length"] = @body.size
      @headers["Connection"] = "Close"
      headers_str
    end

    def head
      reason = REASONS[status]
      "HTTP/1.1 #{@status} #{reason}\r\n#{headers_output}"
    end

    def headers=(raw_headers)
      raw_headers.each_pair do |name, value|
        @headers[name] = value
      end
    end

    def body=(stream)
      stream.each do |chunk|
        @body << chunk
      end
    end

    def close
      @body.close
    end

    def headers_str
      @headers.inject('') { |out, (name, value)| out << HEADER_FORMAT % [name, value] }
    end
  end
end
