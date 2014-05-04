require 'ipaddr'

MiniTest.after_run do
  ip_regex = /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/

  Ghost::Host.any_instance.stub(:resolve_ip) do |ip_or_hostname|
    if ip_or_hostname =~ ip_regex
      ip_or_hostname
    else
      raise "Don't resolve in tests!"
    end
  end
end
