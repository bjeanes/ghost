require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/host'

describe Ghost::Host do
  describe 'attributes' do
    subject { Ghost::Host.new('google.com', '74.125.225.102') }

    its(:name)       { should == 'google.com' }
    its(:to_s)       { should == 'google.com' }
    its(:host)       { should == 'google.com' }
    its(:hostname)   { should == 'google.com' }
    its(:ip)         { should == '74.125.225.102'}
    its(:ip_address) { should == '74.125.225.102'}

    describe "#delete"
  end
end
