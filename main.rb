require './server1.rb'
require './client.rb'



puts "Client - 0, Server - 1"
message = $stdin.gets.chomp
choice = message
puts "Press enter or input id and port:"
message = $stdin.gets.chomp
ip_address, port = message.split
if choice == '0'
  Client.new ip_address: (ip_address or 'localhost'), port: (port or 3000)
else 
  Server.new ip_address: (ip_address or 'localhost'), port: (port or 3000)
end

