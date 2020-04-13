module Blip
  class Server
    def initialize(port, app)
      @socket = TCPServer.new(port)
      @app = app
    end

    def start(workers = 1)
      workers.times do
        fork do
          puts "Forked #{Process.pid}"
          run
        end
      end
      Process.waitall
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
