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
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfile_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) d000000000000000000000000000000000000000000010111000110111101o
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@heade000000000000000000000000000000000000000000010111000110111101r_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbe000000000000000000000000000000000000000000010111000110111101rs_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size umbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.ckage_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb000000000000000000000000000000000000000000010111000110111101| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_fileeof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_positio000000000000000000000000000000000000000000010111000110111101n.to_i
    #size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_s000000000000000000000000000000000000000000010111000110111101ize, signal=  puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_cmber) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_uplo000000000000000000000000000000000000000000010111000110111101ad.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numberses
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do s numbers_downloaded_packages.include?(numbe000000000000000000000000000000000000000000010111000110111101r)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_se
    end
  end
  #header size = 60
  def h000000000000000000000000000000000000000000010111000110111101eader_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size  initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts000000000000000000000000000000000000000000010111000110111101 package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size le.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Ser, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal ==000000000000000000000000000000000000000000010111000110111101 "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? heaf") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= p000000000000000000000000000000000000000000010111000110111101ackage_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_nu000000000000000000000000000000000000000000010111000110111101mber * (@package_size-@header_size)
      package_data = file.read(@package_size-@hekage_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
   urn true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" %000000000000000000000000000000000000000000010111000110111101 package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file, "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
 00000000000000010111000110111101ge_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_nam00000000000000010111000110111101(file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upl * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
   000000000000000000000000000000000000000000010111000110111101   puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_down    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, number000000000000000000000000000000000000000000010111000110111101s_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == d!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initi000000000000000000000000000000000000000000010111000110111101alize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_pacheader_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.clo000000000000000000000000000000000000000000010111000110111101se
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
   )
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.000000000000000000000000000000000000000000010111000110111101push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_paackage_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded0000000000000000000000000000000000000000 file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
 0000000000000000000000000000000000000000  end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_si000000000000000000000000000000000000000000010111000110111101ze = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
   
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.re= 'success'
      puts "File #{file_name} successfully uploaded!"
      retu000000000000000000000000000000000000000000010111000110111101rn true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers= file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_000000000000000000000000000000000000000000010111000110111101to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_pnumbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, number000000000000000000000000000000000000000000010111000110111101s_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbe_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_kages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answ000000000000000000000000000000000000000000010111000110111101er == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, 
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  e000000000000000000000000000000000000000000010111000110111101nd

  def send_file file_name, file_position=0
    ftion.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts '000000000000000000000000000000000000000000010111000110111101Send message OOB'
      puts "Sent #{send_size} byte    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (ers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      000000000000000000000000000000000000000000010111000110111101package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
    rn true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size /s_to000000000000000000000000000000000000000000010111000110111101_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
  i} +000000000000000000000000000000000000000000010111000110111101 numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_packa"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wa000000000000000000000000000000000000000000010111000110111101it_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_heheader + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
 ) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="s000000000000000000000000000000000000000000010111000110111101end"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@hader_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
     000000000000000000000000000000000000000000010111000110111101 package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(packag.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
   000000000000000000000000000000000000000000010111000110111101 send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
  
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message es = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp pack000000000000000000000000000000000000000000010111000110111101age_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @= '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.00000000   binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    hea00000000d

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(num = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.000000000000000000000000000000000000000000010111000110111101size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    enition.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@packa000000000000000000000000000000000000000000010111000110111101ge_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_numbe000000000000000000000000000000000000000000010111000110111101r
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size =     @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      000000000000000000000000000000000000000000010111000110111101send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, fts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (000000000000000000000000000000000000000000010111000110111101@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File 000000000000000000000000000000000000000000010111000110111101#{file_name} successckages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_000000000000000000000000000000000000000000010111000110111101upload.size, "eof") )
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_pa      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, 000000000000000000000000000000000000000000010111000110111101address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.p# binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
nding.pry
    file.close
    message000000000000000000000000000000000000000000010111000110111101 = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_uplors_packages_to_upload.push(number) u000000000000000000000000000000000000000000010111000110111101nless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data =  file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
    000000000000000000000000000000000000000000010111000110111101  send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@hea 0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size000000000000000000000000000000000000000000010111000110111101 -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if sd
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @h000000000000000000000000000000000000000000010111000110111101eader_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @hea
  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    el000000000000000000000000000000000000000000010111000110111101se
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_sd message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name,en("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each000000000000000000000000000000000000000000010111000110111101 do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message =s = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_positi000000010111000110111101ackages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
 000000010111000110111101'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signaze
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send000000000000000000000000000000000000000000010111000110111101_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if fi "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfull_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message O000000000000000000000000000000000000000000010111000110111101OB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_    file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header000000000000000000000000000000000000000000010111000110111101 = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = packet.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
 000000000000000000000000000000000000000000010111000110111101   0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = firs_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.sende_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downl000000000000000000000000000000000000000000010111000110111101oaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_sizsize = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(000000000000000000000000000000000000000000010111 > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    heade000000000000000000000000000000000000000000010111ts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = pac000000000000000000000000000000000000000000010111000110111101kage_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_pac     send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |nummbers_downloaded_packages.include?(number)
    end
    send_size = f000000000000000000000000000000000000000000010111000110111101ile_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(   end
  end
  #header size = 60
  def header_udp package_number, fi000000000000000000000000000000000000000000010111000110111101le_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + nutialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      bin000000000000000000000000000000000000000000010111000110111101ding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= plose
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #ocket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  d000000000000000000000000000000000000000000010111000110111101ef send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_: header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
 000000000000000000000000000000000000000000010111000110111101   file.close
    message = @socket.recv(80000)
    answer, = 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@heade000000000000000000000000000000000000000000010111000110111101r_size)
      package_data = file.read(@package_size-@header_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      ptrue
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0000000000000000000000000000000000000000000010111000110111101" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file filb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
     00000000000000000000000000000000000000010111000110111101socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}",00000000000000000000000000000000000000010111000110111101@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} s000000000000000000000000000000000000000000010111000110111101uccessfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloadpackages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |paze-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "000000000000000000000000000000000000000000010111000110111101eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_packag eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
 000000000000000000000000000000000000000000010111000110111101   @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_packageer_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.rec000000000000000000000000000000000000000000010111000110111101v(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      r    return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_000000000000000000000000000000000000000000010111000110111101downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@a_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_ud0000000000000000e_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_he0000000000000000d
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_pac  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size000000000000000000000000000000000000000000010111000110111101 = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      p   puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(5uccess'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_000000000000000000000000000000000000000000010111000110111101file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_dowle_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_n000000000000000000000000000000000000000000010111000110111101umber|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(f  end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

  000000000000000000000000000000000000000000010111000110111101  file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_heade00)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "000000000000000000000000000000000000000000010111000110111101File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = age_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_nam000000000000000000000000000000000000000000010111000110111101e, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_fil  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts000000000000000000000000000000000000000000010111000110111101 "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_numb_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ?000000000000000000000000000000000000000000010111000110111101 header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    fe.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(pack000000000000000000000000000000000000000000010111000110111101ages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "Fil else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages000000000000000000000000000000000000000000010111000110111101
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
   000000000000000000000000000000000000000000010111000110111101 # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header.size
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket"send"
    header = "%0#{@header_file_size}b" % file_size
    header[0] = "0" if signal == "send"
  000000000000000000000000000000000000000000010111000110111101  header[0] = "1" if signal == "eof"
    puts header.size
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : hea   package = package_header + package_data
      send_size += @address? @socket.send(package,0,@addr000000000000000000000000000000000000000000010111000110111101ess) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) u   send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.e000000000000000000000000000000000000000000010111000110111101ach do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      returnckage_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
@header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload =ackages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package000000000000000000000000000000000000000000010111000110111101_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      nnumbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_s000000000000000000000000000000000000000000010111000110111101ize-@header_pto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_000000000000000000000000000000000000000000010111000110111101packages = npackages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signaass SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_pos000000000000000000000000000000000000000000010111000110111101ition.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0nd
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)000000000000000000000000000000000000000000010111000110111101
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_package    numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(pa000000000000000000000000000000000000000000010111000110111101ckage_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
   numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numb000000000000000000000000000000000000000000010111000110111101ers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_page_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    iully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
   000000000000000000000000000000000000000000010111000110111101 end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socke = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@pack000000000000000000000000000000000000000000010111000110111101age_size-@header_file_size)
      puts package_data.size
      binding.pry if file.ef") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "000000000000000000000000000000000000000000010111000110111101send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp ffile = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socke000000000000000000000000000000000000000000010111000110111101t.send(package,0)
      send_size -= package_header.size
    end
    file.close
    s_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |packa000000000000000000000000000000000000000000010111000110111101ge_number|
      file.pos = package_number * (@package_size-@header_size)
      packge_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package =000000000000000000000000000000000000000000010111000110111101 "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "sepackage + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.s000000000000000000000000000000000000000000010111000110111101ize)
      puts package_header + package_data
      send_size += @socket.send(package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{fi000000000000000000000000000000000000000000010111000110111101le_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_fes_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = messag000000000000000000000000000000000000000000010111000110111101e.split
    if answer == 'success'
      puts "File #{file_name} successfully uploadbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eo000000000000000000000000000000000000000000010111000110111101f? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end000000000000000000000000000000000000000000010111000110111101
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size =
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
     0000000000000000000000000000000000000000
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |num0000000000000000000000000000000000000000sh(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(ader_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {000000000000000000000000000000000000000000010111000110111101|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_numckage_number, numbers_packages_to_upload.size)
      send_size += @socket.se000000000000000000000000000000000000000000010111000110111101nd(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
24
    @address = address
    # @header_package_data = 60
    @header_file_s000000000000000000000000000000000000000000010111000110111101ize = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_na    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_na000000000000000000000000000000000000000000010111000110111101me} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      putb_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rbsize).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = fi000000000000000000000000000000000000000000010111000110111101le_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    iflly uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_s000000000000000000000000000000000000000000010111000110111101erver file_name, file_position, numbers_downloaded_pages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *number000000000000000000000000000000000000000000010111000110111101s_packages = message.split
    if answer == 'success  return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package =  = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @o000000000000000000000000000000000000000000010111000110111101ob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.si += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      size000000000000000000000000000000000000000000010111000110111101
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_nle.r000000000000000000000000000000000000000000010111000110111101ead(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@addreder.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_si000000000000000000000000000000000000000000010111000110111101ze).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.eaackage_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
  ile_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = num000000000000000000000000000000000000000000010111000110111101bers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_sizr_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
   000000000000000000000000000000000000000000010111000110111101 file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      packauts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end000000000000000000000000000000000000000000010111000110111101 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    puts header.size
    heade == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaosition.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, 000000000000000000000000000000000000000000010111000110111101numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_d
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded00000000s.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #00000000ize = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = file_position.to_i
    file.pos = file_position.to_i
    #wait_signal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@head000000000000000000000000000000000000000000010111000110111101er_file_size)
      puts package_data.size
      binding.pry if file.eof?
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header + package_data
      send_size += @socket.send(package_header + package_data, 0)
      
      send_size -= package_header.size
      
    end
    binding.pry
    file.close
    message = @sockwer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
 "%0#{@header_file_size}b" % file_size
    puts header.size
    header[0] = "0" if signal == "send"
    head000000000000000000000000000000000000000000010111000110111101er[0] = "1" if signal == "eof"
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_to_upload.size, "eof") : header_udp(package_nume_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package000000000000000000000000000000000000000000010111000110111101,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_upload = []
    0.upto(packages_count-1) do |number|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
   000000000000000000000000000000000000000000010111000110111101   file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header_udp(package_number, numbers_packages_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_000000000000000000000000000000000000000000010111000110111101number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package + eof
  end
end
class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 1024
    @address = address
    # @header_package_data = 60
    @header_file_size = 60
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
    @oob_char = '!'
    @socket = socket
  end

  def send_file file_name, file_position=0
    file = open("./#{file_name}", "rb")
    send_size = fileignal_int(send_size)
    # binding.pry
    while file.size > send_size
      package_data = file.read(@package_size-@header_file_size)
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      puts package_header.size
      send_size += @socket.send(packag000000000000000000000000000000000000000000010111000110111101e_header + package_d
    end
    binding.pry
    file.close
    message = @socket.recv(50)
    answer, file_size = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      send_file(file_name, file_size)
      return false
    end   
  end
  
  def wait_signal_int send_size
    Signal.trap(:INT) do
      puts 'Send message OOB'
      puts "Sent #{send_size} bytes to socket"
      @socket.send(@oob_char, Socket::MSG_OOB)
    end
  end 
  
  def header file_size, signal="send"
    header = "%0#{@header_file_size}b" % file_size
    header[0] = "0" if signal == "send"
    header[0] = "1" if signal == "eof"
    puts header.size
    header
  end

  def send_file_udp file_name, file_position, numbers_downloaded_packages=[]
    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f000000000000000000000000000000000000000000010111000110111101).ceil
    numbers_per|
      numbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      prs_packages_to_upload.size, "eof") : header_udp(package_number, numbers_packages_to_upload.size)
      package = package_header + package_data
      send_size += @address? @socket.send(package,0,@address) : @socket.send(package,0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully upload000000000000000000000000000000000000000000010111000110111101ed!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end

  def send_file_udp_server file_name, file_position, numbers_downloaded_packages=[]

    file = open("./#{file_name}", "rb")
    packages_count = (file.size / (@package_size-@header_size).to_f).ceil
    numbers_packages_to_umbers_packages_to_upload.push(number) unless numbers_downloaded_packages.include?(number)
    end
    send_size = file_position.to_i
    file.pos = file_position.to_i
    numbers_packages_to_upload.each do |package_number|
      file.pos = package_number * (@package_size-@header_size)
      package_data = file.read(@package_size-@header_size)
      package_head_to_upload.size, "eof") : header_udp100000000000000000000000000000000000000000010111000110111101(package_number, numbers_packages_to_upload.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
    file.close
    message = @socket.recv(80000)
    answer, file_size, *numbers_packages = message.split
    if answer == 'success'
      puts "File #{file_name} successfully uploaded!"
      return true
    else
      numbers_packages = numbers_packages.map {|numb| numb.to_i} + numbers_downloaded_packages
      send_file_udp(file_name, file_size, numbers_packages)
      return false
    end
  end
  #header size = 60
  def header_udp package_number, file_size, signal="send"
    file_size = "%0#{@header_file_size}b" % file_size
    number_package = "%0#{@header_number_package_size}b" % package_number
    eof = "0" if signal == "send"
    eof = "1" if signal == "eof"
    file_size + number_package