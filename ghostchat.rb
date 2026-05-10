#!/usr/bin/env ruby
# author : Monji
# telegram : https://t.me/DevCrr
# GitHub : https://github.com/monji024

require 'socket'
require 'openssl'
require 'base64'
require 'json'
require 'io/console'
require 'thread'

VERSION = "1.1"
PORT = 5550

COLORS = {
  red: "\033[1;31m",
  green: "\033[1;32m",
  cyan: "\033[0;36m",
  yellow: "\033[1;33m",
  magenta: "\033[1;35m",
  white: "\033[1;37m",
  black_bg: "\033[40m",
  bold: "\033[1m",
  reset: "\033[0m"
}

def colorize(text, *codes)
  codes.map { |c| COLORS[c] }.join + text + COLORS[:reset]
end

def clear_screen
  system("clear")
end

def banner
  puts colorize("
   ██████╗  ██╗  ██╗ ██████╗ ███████╗████████╗ 
   ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
   ██║  ███╗███████║██║   ██║███████╗   ██║   
   ██║   ██║██╔══██║██║   ██║╚════██║   ██║  
   ╚██████╔╝██║  ██║╚██████╔╝███████╗   ██║  
    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   
  ", :cyan)
  puts colorize("      Ghost Chat v#{VERSION}", :yellow)
  puts
end

class Crypto
  ITERATIONS = 600000

  def self.encrypt(plain, password)
    return nil if password.to_s.empty?
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    salt = OpenSSL::Random.random_bytes(16)
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, ITERATIONS, 32 + 16, 'sha256')
    key = key_iv[0...32]
    iv = key_iv[32..-1]
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(plain) + cipher.final
    result = salt + encrypted
    Base64.strict_encode64(result)
  rescue
    nil
  end

  def self.decrypt(data_b64, password)
    return nil if password.to_s.empty?
    raw = Base64.decode64(data_b64)
    salt = raw[0...16]
    encrypted = raw[16..-1]
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, ITERATIONS, 32 + 16, 'sha256')
    key = key_iv[0...32]
    iv = key_iv[32..-1]
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    decipher.update(encrypted) + decipher.final
  rescue
    nil
  end
end

class ChatServer
  attr_reader :client_count

  def initialize(port, password, quiet = false)
    @port = port
    @password = password
    @clients = []
    @clients_mutex = Mutex.new
    @server = nil
    @running = true
    @client_count = 0
    @quiet = quiet
  end

  def log(msg)
    return if @quiet
    $stderr.puts msg
  end

  def start
    @server = TCPServer.new('0.0.0.0', @port)
    log colorize("[*] Secure chat server listening on port #{@port}", :green)
    while @running
      begin
        client = @server.accept
        Thread.new(client) { |c| handle_client(c) }
      rescue IOError, Errno::EBADF
        break
      rescue => e
        log colorize("[!] Server error: #{e.message}", :red) if @running
      end
    end
  end

  def stop
    @running = false
    @server.close if @server && !@server.closed?
    @clients_mutex.synchronize do
      @clients.each { |c| c.close rescue nil }
      @clients.clear
      @client_count = 0
    end
  end

  def update_count
    @clients_mutex.synchronize { @client_count = @clients.size }
  end

  def broadcast_system(type, value)
    msg = "__SYS__||#{type}||#{value}"
    @clients_mutex.synchronize do
      @clients.each do |c|
        encrypted = Crypto.encrypt(msg, @password)
        c.puts(encrypted) if encrypted
      end
    end
  end

  private

  def handle_client(client)
    begin
      auth_line = client.gets(chomp: true)
      return unless auth_line
      decrypted = Crypto.decrypt(auth_line, @password)
      return unless decrypted && decrypted.start_with?("AUTH||")
      sent_password = decrypted.split("||", 2)[1]
      if sent_password != @password
        client.puts("AUTH_FAILED")
        client.close
        return
      end
    rescue
      client.close
      return
    end

    @clients_mutex.synchronize { @clients << client }
    update_count
    log colorize("[+] New client joined (total: #{@client_count})", :green)
    broadcast_system("ONLINE", @client_count)

    while line = client.gets(chomp: true)
      decrypted = Crypto.decrypt(line, @password)
      next unless decrypted
      broadcast(decrypted, client)
    end
  rescue EOFError, Errno::ECONNRESET
  ensure
    @clients_mutex.synchronize { @clients.delete(client) }
    update_count
    broadcast_system("ONLINE", @client_count)
    client.close rescue nil
    log colorize("[-] Client left (remaining: #{@client_count})", :yellow)
  end

  def broadcast(message, sender)
    @clients_mutex.synchronize do
      @clients.each do |c|
        next if c == sender
        encrypted = Crypto.encrypt(message, @password)
        c.puts(encrypted) if encrypted
      end
    end
  end
end
class StatusBar
  def initialize(host, port, username)
    @host = host
    @port = port
    @username = username
    @running = true
    @mutex = Mutex.new
    @current_online = 0
    @last_text = ""
  end

  def start
    @thread = Thread.new do
      while @running
        draw
        sleep 1
      end
    end
  end

  def stop
    @running = false
    @thread.join if @thread
  end

  def update_online(count)
    @mutex.synchronize { @current_online = count }
  end

  def draw
    @mutex.synchronize do
      cols = `tput cols`.to_i rescue 80
      cols = 80 if cols <= 0

      ip_display = (@host == "127.0.0.1" || @host == "localhost") ? get_local_ip : @host
      online_text = colorize(@current_online.to_s, :green)

      status_text = "  #{ip_display}:#{@port}  |   Online: #{online_text}"
      return if status_text == @last_text
      @last_text = status_text
      
      clean_text = status_text.gsub(/\e\[[0-9;]*m/, '')
      padding = (cols - clean_text.length) / 2
      padding = 0 if padding < 0
      print "\e7"
      print "\e[1A"
      print "\r"
      print "\e[2K"
      print colorize("\033[40m\033[37m" * padding + status_text, :black_bg)
      print "\n"
      print "\e8"
      $stdout.flush
    end
  end

  private

  def get_local_ip
    ip = `ip route get 1 2>/dev/null`.split("\n")[0]&.match(/src (\S+)/)&.[](1)
    if ip.nil? || ip.empty?
      ip = `ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1`.strip
    end
    ip = "127.0.0.1" if ip.nil? || ip.empty?
    ip
  end
end

class ChatClient
  def initialize(host, port, password, username)
    @host = host
    @port = port
    @password = password
    @username = username
    @running = true
    @socket = nil
    @status_bar = nil
    @write_mutex = Mutex.new
  end

  def run
    begin
      @socket = TCPSocket.new(@host, @port)

      auth_msg = "AUTH||#{@password}"
      encrypted_auth = Crypto.encrypt(auth_msg, @password)
      unless encrypted_auth
        puts colorize("\n[!] Encryption failed (empty password?).", :red)
        sleep 2
        return
      end
      @socket.puts(encrypted_auth)

      clear_screen
      banner
      puts colorize("┌─[✓] Connected to #{@host}:#{@port}", :green)
      puts colorize("├─[*] Group chat active. Type 'exit' to quit.", :green)
      puts colorize("└─────────────────────────────────────────", :green)
      puts

      @status_bar = StatusBar.new(@host, @port, @username)
      @status_bar.start

      sleep 0.2

      reader = Thread.new { read_messages }

      while @running
        print colorize("└─[#{@username}] > ", :green, :cyan)
        msg = $stdin.gets&.chomp
        break if msg.nil?

        case msg
        when "exit"
          break
        when "clear"
          # clear_screen
          banner
          puts colorize("┌─[✓] Connected to #{@host}:#{@port}", :green)
          puts colorize("├─[*] Group chat active. Type 'exit' to quit.", :green)
          puts colorize("└─────────────────────────────────────────", :green)
          puts
          @status_bar.draw
          next
        when ""
          next
        else
          payload = "#{@username}||#{msg}"
          encrypted = Crypto.encrypt(payload, @password)
          @socket.puts(encrypted) if encrypted
        end
      end
    rescue Errno::ECONNREFUSED
      puts colorize("\n[!] Connection refused! Server is not running.", :red)
      sleep 2
    rescue => e
      puts colorize("\n[!] Error: #{e.message}", :red)
      sleep 2
    ensure
      @running = false
      @status_bar.stop if @status_bar
      reader.kill if reader && reader.alive?
      @socket.close if @socket && !@socket.closed?
      puts colorize("\n[!] Disconnected.", :yellow)
      sleep 1.5
    end
  end

  private

  def read_messages
    while @running && @socket && !@socket.closed?
      begin
        line = @socket.gets(chomp: true)
        if line.nil?
          puts colorize("\n[!] Connection lost or authentication failed.", :red)
          @running = false
          break
        end
        decrypted = Crypto.decrypt(line, @password)
        next unless decrypted

        if decrypted.start_with?("__SYS__||")
          parts = decrypted.split("||", 4)
          if parts[1] == "ONLINE"
            count = parts[2].to_i
            @status_bar.update_online(count) if @status_bar
          end
          next
        end

        sender, message = decrypted.split("||", 2)
        @write_mutex.synchronize do
          print "\r\e[K"
          puts colorize("┌─[#{sender}] > #{message}", :green, :cyan)
          print colorize("└─[#{@username}] > ", :green, :cyan)
          $stdout.flush
        end
      rescue IOError, EOFError
        puts colorize("\n[!] Disconnected from server.", :yellow)
        @running = false
        break
      end
    end
  end
end
class NgrokManager
  @ngrok_pid = nil

  def self.start_tunnel(port, auth_token)
    stop
    @ngrok_pid = spawn("ngrok tcp #{port} --authtoken #{auth_token}", [:out, :err] => "/dev/null")
    sleep 4

    url = nil
    15.times do
      begin
        resp = `curl -s http://localhost:4040/api/tunnels`
        data = JSON.parse(resp)
        tunnel = data['tunnels']&.find { |t| t['proto'] == 'tcp' }
        if tunnel
          url = tunnel['public_url']
          break
        end
      rescue
        sleep 1
      end
    end

    if url
      url
    else
      stop
      nil
    end
  end

  def self.stop
    if @ngrok_pid
      Process.kill('TERM', @ngrok_pid) rescue nil
      @ngrok_pid = nil
    end
  end
end

def get_local_ip
  ip = `ip route get 1 2>/dev/null`.split("\n")[0]&.match(/src (\S+)/)&.[](1)
  if ip.nil? || ip.empty?
    ip = `ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1`.strip
  end
  ip = "127.0.0.1" if ip.nil? || ip.empty?
  ip
end

def get_username
  print colorize("┌─[?] Your username: ", :green, :cyan)
  username = $stdin.gets.chomp
  username = "Anonymous" if username.empty?
  username
end

def show_ip
  my_ip = get_local_ip
  puts
  puts colorize("  🌐  Your Local IP: #{my_ip}  ", :black_bg, :white)
  puts
end

def free_port(port)
  system("fuser -k #{port}/tcp 2>/dev/null")
  system("lsof -ti :#{port} | xargs kill -9 2>/dev/null")
  sleep 1
end

def host_local(username)
  clear_screen
  banner
  print colorize("┌─[?] Room password: ", :green, :cyan)
  pass = $stdin.noecho(&:gets).chomp
  puts
  if pass.empty?
    puts colorize("[!] Password cannot be empty.", :red)
    sleep 2
    return
  end

  show_ip
  puts colorize("├─[*] Starting secure group chat server on port #{PORT}...", :green)
  free_port(PORT)

  server = ChatServer.new(PORT, pass, true)
  Thread.new { server.start }

  sleep 1
  puts colorize("├─[✓] Group chat server running", :green)
  puts colorize("├─[!] Share your local IP and password with friends", :yellow)
  puts colorize("└─[*] You are now joining the room...", :green)
  puts

  client = ChatClient.new("127.0.0.1", PORT, pass, username)
  client.run
ensure
  server&.stop
  free_port(PORT)
end

def join_local(username)
  clear_screen
  banner
  print colorize("┌─[?] Host IP (local): ", :green, :cyan)
  host_ip = $stdin.gets.chomp
  print colorize("└─[?] Room password: ", :green, :cyan)
  pass = $stdin.noecho(&:gets).chomp
  puts
  client = ChatClient.new(host_ip, PORT, pass, username)
  client.run
end

def host_ngrok(username)
  clear_screen
  banner
  print colorize("┌─[?] Room password: ", :green, :cyan)
  pass = $stdin.noecho(&:gets).chomp
  puts
  if pass.empty?
    puts colorize("[!] Password cannot be empty.", :red)
    sleep 2
    return
  end

  print colorize("├─[?] Enter ngrok auth token: ", :yellow, :cyan)
  token = $stdin.noecho(&:gets).chomp
  puts
  free_port(PORT)

  server = ChatServer.new(PORT, pass, true)
  Thread.new { server.start }

  puts colorize("├─[*] Starting ngrok on port #{PORT}...", :green)
  url = NgrokManager.start_tunnel(PORT, token)
  unless url
    puts colorize("└─[!] Ngrok failed. Check token and internet.", :red)
    server.stop
    free_port(PORT)
    sleep 2
    return
  end

  clear_screen
  banner
  puts colorize("┌─[✓] Global secure group chat active!", :green)
  puts
  puts colorize("  🌍  Share this address: #{url}  ", :black_bg, :white)
  puts
  puts colorize("└─[*] You are now joining the room...", :green)
  puts

  client = ChatClient.new("127.0.0.1", PORT, pass, username)
  client.run
ensure
  server&.stop
  NgrokManager.stop
  free_port(PORT)
end

def join_ngrok(username)
  clear_screen
  banner
  print colorize("┌─[?] Global address (tcp://...): ", :green, :cyan)
  addr = $stdin.gets.chomp
  if addr =~ /tcp:\/\/([^:]+):(\d+)/
    host_ip = Regexp.last_match(1)
    host_port = Regexp.last_match(2).to_i
  else
    puts colorize("[!] Invalid address format", :red)
    sleep 2
    return
  end
  print colorize("└─[?] Room password: ", :green, :cyan)
  pass = $stdin.noecho(&:gets).chomp
  puts
  client = ChatClient.new(host_ip, host_port, pass, username)
  client.run
end

def main_menu
  loop do
    clear_screen
    banner
    username = get_username
    clear_screen
    banner
    puts
    puts colorize("  [1] Host - Local (LAN)        ", :green)
    puts colorize("  [2] Join - Local (LAN)        ", :green)
    puts colorize("  [3] Host - Global (ngrok)     ", :green)
    puts colorize("  [4] Join - Global (ngrok)     ", :green)
    puts colorize("  [5] Exit                      ", :green)
    print colorize(" └[?] Choose → ", :yellow)
    choice = $stdin.gets.chomp

    case choice
    when "1" then host_local(username)
    when "2" then join_local(username)
    when "3" then host_ngrok(username)
    when "4" then join_ngrok(username)
    when "5"
      clear_screen
      puts colorize("Goodbye!", :green)
      exit 0
    else
      puts colorize("└─[!] Invalid choice", :red)
      sleep 1
    end
  end
end

if __FILE__ == $0
  begin
    main_menu
  rescue Interrupt
    clear_screen
    puts colorize("\n[!] Interrupted", :yellow)
    puts colorize("bay", :green)
    exit 0
  end
end
