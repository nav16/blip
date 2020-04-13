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
      until readable?
        data = @client.readpartial(CHUNK_SIZE)
        @request.parser << data

        break if @request.parsed
      end
      @request.parse!
      @env = @request.env

      respond
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

    def readable?
      @client.closed? || @client.eof?
    end
  end
end
