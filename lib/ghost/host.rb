class Host
  class << self
    def list
      `dscl localhost -list /Local/Default/Hosts`.split
    end
  end
end