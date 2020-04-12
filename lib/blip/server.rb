require "socket"

module Blip
  class Server
    def initialize
      @socket = TCPServer.new(3001)
    end

    def run
      loop do
        client = @socket.accept
        connection = Connection.new(client)
        connection.process
      end
    end
  end
end
