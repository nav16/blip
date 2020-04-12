module Blip
  class Connection
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def process
      request = Request.new
      until readable?
        data = client.readpartial(1024)
        request.parser << data

        break if request.parsed
      end

      respond
    end

    private

    def respond
      client.write "HTTP/1.1 200 OK\r\n"
      client.write "\r\n"
      client.write "Eureka"

      close
    end

    def close
      client.close
    end

    def readable?
      client.closed? || client.eof?
    end
  end
end
