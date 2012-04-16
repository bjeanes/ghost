module Ghost
  class Host < Struct.new(:name, :ip)
    alias :to_s :name
    alias :host :name
    alias :hostname :name
    alias :ip_address :ip

    def <=>(host)
      if ip == host.ip
        name <=> host.name
      else
        ip <=> host.ip
      end
    end
  end
end
