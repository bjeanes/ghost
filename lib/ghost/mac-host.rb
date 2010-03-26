require 'socket'

class Host
  ListCmd = "dscl localhost -list /Local/Default/Hosts 2>&1"
  ReadCmd = "dscl localhost -read /Local/Default/Hosts/%s 2>&1"
  CreateCmd = "sudo dscl localhost -create /Local/Default/Hosts/%s IPAddress %s 2>&1"
  DeleteCmd = "sudo dscl localhost -delete /Local/Default/Hosts/%s 2>&1"
  
  class << self
    protected :new
    
    def list
      list = `#{ListCmd}`
      list = list.split("\n")
      list.collect { |host| Host.new(host.chomp) }
    end

    def add(host, ip = "127.0.0.1", force = false)
      if find_by_host(host).nil? || force
        unless ip[/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/]
          ip = Socket.gethostbyname(ip)[3].bytes.to_a.join('.')
        end
        
        `#{CreateCmd % [host, ip]}`
        flush!
        find_by_host(host)
      else
        raise "Can not overwrite existing record"
      end      
    end
    
    def find_by_host(host)
      @hosts ||= {}
      @hosts[host] ||= begin
        output = `#{ReadCmd % host}`
      
        if output =~ /eDSRecordNotFound/
          nil
        else
          host = parse_host(output)
          ip = parse_ip(output)
        
          Host.new(host, ip)
        end
      end
    end
    
    def find_by_ip(ip)
      nil
    end
    
    def empty!
      list.each { |h| delete(h) }
      nil
    end
    
    def delete(host)
      `#{DeleteCmd % host.to_s}`
      flush!
    end
    
    def delete_matching(pattern)
      pattern = Regexp.escape(pattern)
      hosts = list.select { |h| h.to_s.match(/#{pattern}/) }
      hosts.each do |h|
        delete(h)
      end
      flush! unless hosts.empty?
      hosts
    end
    
    # Flushes the DNS Cache
    def flush!
      `dscacheutil -flushcache`
      @hosts = {}
      true
    end
    
    protected
    def parse_host(output)
      parse_value(output, 'RecordName')
    end
    
    def parse_ip(output)
      parse_value(output, 'IPAddress')
    end
    
    def parse_value(output, key)
      match = output.match(Regexp.new("^#{key}: (.*)$"))
      match[1] unless match.nil?
    end
  end
  
  def initialize(host, ip=nil)
    @host = host
    @ip = ip
  end
  
  def hostname
    @host
  end
  alias :to_s :hostname
  alias :host :hostname
  alias :name :hostname
  
  def ip
    @ip ||= self.class.send(:parse_ip, dump)
  end
  
  private
  def dump
    @dump ||= `#{ReadCmd % hostname}`
  end
end
