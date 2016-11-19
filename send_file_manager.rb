class SendFileManager
  def initialize(socket, address=nil)
    @package_size = 8192
    @address = address
    # @header_package_data = 60
    @header_file_size = 40
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
    wait_signal_int(send_size)
    while file.size > send_size
      package_data = file.read(@package_size-@header_size)
      package_header = file.eof? ? header(file.size, "eof") : header(file.size)
      send_size += @socket.send(package_header + package_data, 0)
      send_size -= package_header.size
    end
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
    header = "%0#{@header_size}b" % file_size
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
