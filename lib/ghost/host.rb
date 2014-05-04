require 'socket'

module Ghost
  class Host < Struct.new(:name, :ip)
    class NotResolvable < StandardError; end

    alias :to_s :name
    alias :host :name
    alias :hostname :name
    alias :ip_address :ip

    def initialize(host, ip = "127.0.0.1")
      super(host, resolve_ip(ip))
    end

    def <=>(host)
      if ip == host.ip
        name <=> host.name
      else
        ip <=> host.ip
      end
    end

    def match(name)
      host.match(name)
    end

    def resolve_ip(ip_or_hostname)
      IPSocket.getaddress(ip_or_hostname)
    rescue SocketError
      raise Ghost::Host::NotResolvable, "#{ip_or_hostname} is not resolvable."
    end
  end
end
