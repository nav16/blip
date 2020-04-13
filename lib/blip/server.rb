require "socket"

module Blip
  class Server
    def initialize(port, app)
      @socket = TCPServer.new(port)
      @app = app
    end

    def run
      loop do
        client = @socket.accept
        connection = Connection.new(client, @app)
        connection.process
      end
    end
  end
end
