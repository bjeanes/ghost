class Host
  ListCmd = "dscl localhost -list /Local/Default/Hosts 2>&1"
  ReadCmd = "dscl localhost -read /Local/Default/Hosts/%s 2>&1"
  CreateCmd = "sudo dscl localhost -create /Local/Default/Hosts/%s IPADDRESS %s 2>&1"
  DeleteCmd = "sudo dscl localhost -delete /Local/Default/Hosts/%s 2>&1"
  
  class << self
    protected :new
    
    def list(bypass_cache = false)
      if bypass_cache
        @cache = get_list
      else
        @cache ||= get_list
      end
    end

    def add(host, ip = "127.0.0.1")
      `#{CreateCmd % [host, ip]}`
      flush!
      find_by_host(host)
    end
    
    def find_by_host(host)
      output = `#{ReadCmd % host}`
      
      if output =~ /eDSRecordNotFound/
        nil
      else
        host = parse_host(output)
        ip = parse_ip(output)
        
        Host.new(host, ip)
      end
    end
    
    def find_by_ip(ip)
      nil
    end
    
    def empty!
      list.each {|h| delete(h) }
    end
    
    def delete(host)
      `#{DeleteCmd % host.to_s}`
      flush!
    end
    
    # Flushes the DNS Cache
    def flush!
      `dscacheutil -flushcache`
      @cache = nil
    end
    
    protected
    def get_list
      list = `#{ListCmd}`
      list.collect { |host| Host.new(host.chomp) }
    end
    
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
    @hostname
  end
  alias :to_s :hostname
  
  def ip
    @ip ||= self.class.send(:parse_ip, dump)
  end
  
  private
  def dump
    @dump ||= `#{ReadCmd % hostname}`
  end
end
