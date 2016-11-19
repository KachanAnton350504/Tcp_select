require './server1.rb'
require './client.rb'



puts "Client - 0, Server - 1"
message = $stdin.gets.chomp
choice, port = message.split
if message == '0'
  Client.new port: 3004   
else 
  Server.new port: 3004
end

