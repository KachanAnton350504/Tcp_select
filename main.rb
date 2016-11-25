require './server1.rb'
require './client.rb'



puts "Client - 0, Server - 1"
message = $stdin.gets.chomp
choice = message
puts "Press enter or input id and port:"
message = $stdin.gets.chomp
 port, ip_address = message.split
if choice == '0'
  Client.new ip_address: (ip_address or '192.168.1.101'), port: (port or 3000)
else 
  Server.new ip_address: (ip_address or '192.168.1.109'), port: (port or 3000)
end

