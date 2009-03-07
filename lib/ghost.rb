$: << File.dirname(__FILE__)

case RUBY_PLATFORM
when /darwin/
  require 'ghost/mac-host'
when /linux/
  require 'ghost/linux-host'
end
