require 'socket'
require 'pry'
require 'colorize'
require './send_file_manager'
require './recv_file_manager'

class Client
  include Socket::Constants

  def initialize(ip_address: 'localhost', port: '3002')
    @ip_address = ip_address
    @port = port
    connect_to_server
    send_server
  end

  def connect_to_server
    @server = Socket.new(AF_INET, SOCK_STREAM, 0)
    @server.connect( Socket.sockaddr_in(@port, @ip_address) )

    @server_udp = Socket.new(AF_INET, SOCK_DGRAM, 0)
    @server_udp.connect( Socket.sockaddr_in(@port, @ip_address) )
    message = @server.recv(2048)
    print message
    command, *argument = message.split
    send_file(file_name: argument[0], file_position: argument[1]) if command == 'download_continue'
    download_continue(file_name: argument[0]) if command == 'upload_continue'
  end

  def download_continue file_name
    file = File.open("client/#{file_name}", 'rb')
    @server.send "#{file.size}", 0
    file.close
    get_file(file_name: file_name, file_mode: 'a')
  end

  def send_server
    loop do
      message = $stdin.gets.chomp #Ждем ввода сообщения
      @server.send(message + "\n\r",0) #обязательно добавляем \n\r в конец каждой комманды
      command, *argument = message.split #разделяем ввод на команду и аргумент(ну это уже для передачи файлов)
      send_file(file_name: argument[0], protocol: argument[1]) if command == 'upload'
      get_file(file_name: argument[0], protocol: argument[1]) if command == 'download'
      print @server.recv(2048) if command != 'upload' && command != 'download' # и ждем ответа от сервера и выводим(на if не сомтри)
    end
  rescue Errno::ENOENT
    STDERR.puts 'No such file! Use the <ls> command'
  rescue Errno::EPIPE
    STDERR.puts "Connection broke!"
    @server.close
    connect_to_server
  rescue Errno::ECONNRESET
    STDERR.puts "Connection reset by peer!"
  end

  def get_file(file_name: nil, file_mode: 'wb', protocol: 'tcp')
    if protocol == 'udp'
      @server_udp.send('address', 0)
      recver = RecvFileManager.new(@server_udp)
      recver.get_file_udp(file_name, file_mode)
    else
      recver = RecvFileManager.new(@server)
      recver.get_file(file_name, file_mode)
    end
  end

  def send_file (file_name: nil, file_position: 0, protocol: 'tcp')
    if protocol == 'udp'
      sender = SendFileManager.new(@server_udp)
      sender.send_file_udp(file_name, file_position)
    else
      sender = SendFileManager.new(@server)
      sender.send_file(file_name, file_position)
    end
  end

end
