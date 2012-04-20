module Ghost
  class Host < Struct.new(:name, :ip)
    alias :to_s :name
    alias :host :name
    alias :hostname :name
    alias :ip_address :ip

    def initialize(host, ip = "127.0.0.1")
      super(host, ip)
    end

    def <=>(host)
      if ip == host.ip
        name <=> host.name
      else
        ip <=> host.ip
      end
    end
  end
end
