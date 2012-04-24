require 'ipaddr'

RSpec.configure do |c|
  IP_ADDRESS_REGEX = /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/

  c.before do
    Ghost::Host.any_instance.stub(:resolve_ip) do |ip_or_hostname|
      if ip_or_hostname =~ IP_ADDRESS_REGEX
        ip_or_hostname
      else
        raise "Don't resolve in tests!"
      end
    end
  end
end
