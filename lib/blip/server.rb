require 'socket'

module Blip
  class Server

    def initialize
      @socket = TCPServer.new(3001)
    end

    def run
      loop do
        client = @socket.accept

        data = client.readpartial(1024)
        puts data

        client.write "HTTP/1.1 200 OK\r\n"
        client.write "\r\n"
        client.write "Eureka"

        client.close
      end
    end
  end
end

# Blip::Server.new.run