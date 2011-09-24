require 'socket'

class Host
  attr_reader :host, :ip

  def initialize(host, ip)
    @host = host
    @ip = ip
  end
  
  def ==(other)
    @host == other.host && @ip = other.ip
  end
  
  alias :to_s :host
  alias :name :host
  alias :hostname :host
  
  @@hosts_file = '/etc/hosts'
  @@permanent_hosts = [Host.new("localhost",      "127.0.0.1"),
                       Host.new(`hostname`.chomp, "127.0.0.1")]
  class << self
    protected :new
    
    def list
      with_exclusive_file_access do |file|
        entries = []
        file.pos = 0
        file.each do |line|
          next if line =~ /^#/
          if line =~ /^(\d+\.\d+\.\d+\.\d+)\s+(.*)$/
            ip = $1
            hosts = $2.split(/\s+/)
            hosts.each { |host| entries << Host.new(host, ip) }
          end
        end
        entries.delete_if { |host| @@permanent_hosts.include? host }
        entries
      end
    end

    def add(host, ip = "127.0.0.1", force = false)
      with_exclusive_file_access do
        if find_by_host(host).nil? || force
          delete(host)
          
          unless ip[/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/]
            ip = Socket.gethostbyname(ip)[3].bytes.to_a.join('.')
          end
          
          new_host = Host.new(host, ip)
          
          hosts = list
          hosts << new_host
          write_out!(hosts)
          
          new_host
        else
          raise "Can not overwrite existing record"
        end      
      end
    end
    
    def find_by_host(hostname)
      list.find{ |host| host.hostname == hostname }
    end
    
    def find_by_ip(ip)
      list.find_all{ |host| host.ip == ip }
    end
    
    def empty!
      write_out!([])
    end
    
    def delete(name)
      with_exclusive_file_access do
        hosts = list
        hosts = hosts.delete_if { |host| host.name == name }
        write_out!(hosts)
      end
    end
    
    def delete_matching(pattern)
      with_exclusive_file_access do
        pattern = Regexp.escape(pattern)
        hosts = list.select { |host| host.name.match(/#{pattern}/) }
        hosts.each { |host| delete(host.name) }
        hosts
      end
    end

    protected

    def with_exclusive_file_access
      return_val = nil

      if @_file
        return_val = yield @_file
      else
        File.open(@@hosts_file, 'r+') do |f|
          f.flock File::LOCK_EX
          begin
            @_file = f
            return_val = yield f
          ensure
            @_file = nil
          end
        end
      end

      return_val
    end

    def write_out!(hosts)
      with_exclusive_file_access do |f|
        hosts += @@permanent_hosts
        output = hosts.inject("") {|s, h| s + "#{h.ip} #{h.hostname}\n" }
        f.pos = 0
        f.print output
        f.truncate(f.pos)
      end
    end
  end
end
