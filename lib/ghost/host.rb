class Host
  class << self
    def list(bypass_cache = false)
      cmd = 'dscl localhost -list /Local/Default/Hosts'

      if bypass_cache
        @cache = `#{cmd}`.split
      else
        @cache ||= `#{cmd}`.split
      end
    end

    def add(host, ip = "127.0.0.1")
      `dscacheutil -flushcache`
    end
  end
end
