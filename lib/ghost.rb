$: << File.dirname(__FILE__)

module Ghost
  class RecordExists < StandardError
  end
end

require 'rbconfig'

case RbConfig::CONFIG['host_os']
when /darwin/
  productVersion = `/usr/bin/sw_vers -productVersion`.strip
  if productVersion =~ /^10\.7\.[2-9]{1}$/
    require 'ghost/linux-host'
  else
    require 'ghost/mac-host'
  end
when /linux/
  require 'ghost/linux-host'
end

require 'ghost/ssh_config'
require 'ghost/version'
