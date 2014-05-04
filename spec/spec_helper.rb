$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest/autorun'

Dir['./spec/support/*.rb'].each { |f| require(f) }

if __FILE__ == $0
  Dir.glob('./spec/**/*_spec.rb') { |f| require f }
end
