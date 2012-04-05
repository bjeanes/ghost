$: << File.dirname(__FILE__)

case RUBY_PLATFORM
when /darwin/
  productVersion = `/usr/bin/sw_vers -productVersion`.strip
  end
  if productVersion =~ /^10\.7\.[2-9]{1}$/
    require 'ghost/linux-host'
  else
    require 'ghost/mac-host'
  end
when /linux/
  require 'ghost/linux-host'
end

require 'ghost/ssh_config'
