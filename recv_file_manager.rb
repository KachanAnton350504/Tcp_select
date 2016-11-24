require 'fcntl'

class RecvFileManager
  
  F_SETOWN = 8 
  
  def initialize(socket)
    @package_size = 1024
    @header_file_size = 40
    @header_number_package_size = 20
    @header_eof_size = 1
    @header_size = @header_file_size + @header_number_package_size + @header_eof_size
  
    @socket = socket
  end

  def get_file file_name, file_mode='wb'
    puts "Downloading #{file_name}"
    file = File.open("server/#{file_name}", file_mode)
    wait_signal_urg(file)
    download_file_size = write_to_file(file)
    if file.size == download_file_size
      puts 'File successfully downloaded.'
      @socket.send "success", 0, @address
      file.close
      return true
    else
      puts 'Error download.'
      @socket.send "error #{file.size}",0, @address
      file.close
      get_file(file_name, 'a')
    end
    
  end

  def write_to_file file
    while true
      package = @socket.recv(@package_size, Socket::MSG_WAITALL)
      file.print package[@header_size..-1]
      break if signal_eof?(package) || package.empty?
      download_file_size = must_file_size(package)
    end
    binding.pry
    download_file_size
  rescue Errno::EAGAIN
    retry
  end

  def must_file_size package
    header = package[0...@header_size]
    header[0] = "0"
    header.to_i(2)
  end

  def signal_eof? package
    package[0] == "1" ? true : false
  end

  def wait_signal_urg file
    trap(:URG) do
      begin
        puts "got #{file.size} bytes" if @socket.recv(100, Socket::MSG_OOB).eql?('!')
      rescue Exception => err
        puts "got #{file.size} bytes"
      end
    end
    @socket.fcntl(F_SETOWN, Process.pid)       
  end



  def get_file_udp file_name, file_mode='wb'
    puts "Downloading #{file_name}"
    file = File.open("server/#{file_name}", file_mode)
    listen_socket(file)
    true
  end

  def listen_socket file
    @numbers_downloaded_packages = []
    count_packages = write_to_file_udp(file)
    if @numbers_downloaded_packages.size == count_packages
      puts 'File successfully downloaded.'
      @socket.send "success", 0, @address
      file.close
      return true
    else
      puts "#{count_packages - @numbers_downloaded_packages.size} packages left download"
      @socket.send "error #{file.size} #{@numbers_downloaded_packages.join(' ')}", 0, @address
      listen_socket(file)
    end
  end

  def write_to_file_udp file
    while true
      ready = IO.select([@socket], nil, nil, 1)
      if ready
        package, addr = @socket.recvfrom(@package_size)
      else
        break
      end
      count_packages, number_package = parse_header_udp(package)
      file.pos = number_package * (@package_size-@header_size)
      file.print package[@header_size..-1]
      @numbers_downloaded_packages.push(number_package)
      break if signal_eof_udp?(package) || package.empty?
    end
    @address = addr
    count_packages
  rescue Errno::EAGAIN
    retry
  end

  def parse_header_udp package
    header = package[0...@header_size]
    file_size = header[0...@header_file_size].to_i(2)
    number_package = header[@header_file_size...@header_file_size+@header_number_package_size].to_i(2)
    [file_size, number_package]
  end

  def signal_eof_udp? package
    header = package[0...@header_size]
    header[-1] == "1" ? true : false
  end
end
