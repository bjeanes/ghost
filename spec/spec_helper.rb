$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), "support", "*")].each { |f| require(f) }
