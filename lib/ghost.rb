$: << File.dirname(__FILE__)

module Ghost
  class RecordExists < StandardError
  end
end

require 'rbconfig'

case RbConfig::CONFIG['host_os']
when /darwin/
  sw_vers = `/usr/bin/sw_vers -productVersion`.strip
  # use linux-style hosts on Mac OS X Lion and Mountain Lion
  if sw_vers =~ /^10\.7\.[2-9]$/ or sw_vers =~ /^10\.8(\.[0-9])?$/
    require 'ghost/linux-host'
  else
    require 'ghost/mac-host'
  end
when /linux/
  require 'ghost/linux-host'
end

require 'ghost/ssh_config'
