module Blip
  class Server
    def initialize(port, app)
      @socket = TCPServer.new(port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      @app = app
      @children = []
    end

    def start(workers = 1)
      trap_parent_signals

      workers.times do
        @children << fork do
          trap_worker_signals
          puts "Forked #{Process.pid}"
          run
        end
      end

      Process.waitall
    end

    def run
      loop do
        client = @socket.accept
        begin
          Connection.new(client, @app).process
        rescue => e
          $stderr.puts "blip: worker caught #{e.class}: #{e.message}"
          client.close rescue nil
        end
      end
    rescue Interrupt
    end

    private

    def trap_parent_signals
      %w[INT TERM QUIT].each do |sig|
        trap(sig) do
          @children.each { |pid| Process.kill(sig, pid) rescue nil }
        end
      end
    end

    def trap_worker_signals
      %w[INT TERM QUIT].each { |sig| trap(sig) { exit } }
    end
  end
end
