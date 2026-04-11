module Blip
  class Connection

    def initialize(client, app)
      @app = app
      @client = client
      @env = {}
      @request = Request.new(@env)
      @response = Response.new
    end

    def process
      until @request.parsed
        data = @client.readpartial(CHUNK_SIZE)
        @request.parser << data
      end
      @request.parse!
      @env = @request.env

      respond
    rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
      close rescue nil
    rescue HTTP::Parser::Error => e
      $stderr.puts "blip: bad request (#{e.message})"
      send_error(400, "Bad Request")
    rescue => e
      $stderr.puts "blip: #{e.class}: #{e.message}"
      send_error(500, "Internal Server Error")
    end

    private

    def respond
      @response.status, @response.headers, @response.body = @app.call(@env)

      @client.write @response.head
      @client.write "\r\n"

      @response.body.rewind
      @response.body.each do |chunk|
        @client.write chunk
      end

      close
    ensure
      @response.close rescue nil
    end

    def close
      @client.close
    end

    def send_error(status, reason)
      body = "#{status} #{reason}\n"
      @client.write "HTTP/1.1 #{status} #{reason}\r\n"
      @client.write "Content-Type: text/plain\r\n"
      @client.write "Content-Length: #{body.bytesize}\r\n"
      @client.write "Connection: close\r\n\r\n"
      @client.write body
    rescue StandardError
    ensure
      close rescue nil
    end
  end
end
