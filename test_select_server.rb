require 'socket'
include Socket::Constants
require 'pry'
class ChatServer

  def initialize
    @reading = Array.new
    @writing = Array.new
    @clients = Hash.new
  end

  def start
    @server_socket = TCPServer.new('localhost', 4242)
    @reading.push(@server_socket)
    run_acceptor
  end

  private

  def add_client
    socket = @server_socket.accept_nonblock
    socket.send "hello", 0
    @reading.push(socket)

    @clients[socket] = Fiber.new do |message|
      loop {
        if message.nil?
          chat = socket.gets
          socket.flush
          message = Fiber.yield(chat.strip)
        else
          socket.puts("chat: #{message.strip}")
          socket.flush
          message = Fiber.yield
        end
      }
    end
    puts "client #{socket} connected"
    return @clients[socket]
  end

  def broadcast(message)
    @clients.each_pair do |key, value|
      puts "invoking client #{key}"
      value.resume(message)
    end
  end

  def run_acceptor
    puts "accepting on shared socket (localhost:4242)"
      loop do
        puts "current clients: #{@clients.length}"
        readable, writable = IO.select(@reading, @writing)
        binding.pry
        readable.each do |socket|
          if socket == @server_socket
            add_client
          else
            binding.pry
            client = @clients[socket]
            message = client.resume
            binding.pry
            puts "client #{socket} sent: #{message}"
            # broadcast(message)
          end 
        end
      end
  end
end

server = ChatServer.new
server.start
