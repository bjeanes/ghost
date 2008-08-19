$: << File.dirname(__FILE__)
require 'ghost/host'

=begin
  showing hosts
      dscl localhost -list /Local/Default/Hosts
  showing all info for all hosts
      dscl localhost -readall /Local/Default/Hosts
  showing info for single host
      dscl localhost -readall /Local/Default/Hosts/<hostname.local>
  adding hostname
      dscl localhost -read /Local/Default/Hosts/bne-developer.local
=end