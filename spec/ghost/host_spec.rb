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
  end

  it 'has a default IP of 127.0.0.1' do
    Ghost::Host.new('xyz.com').ip.should == '127.0.0.1'
  end

  describe 'equality' do
    it 'is equal to a host with the same hostname and IP' do
      Ghost::Host.new('google.com', '123.123.123.123').should ==
        Ghost::Host.new('google.com', '123.123.123.123')
    end

    it 'is not equal to a host with a different host name' do
      Ghost::Host.new('google.com', '123.123.123.123').should_not ==
        Ghost::Host.new('gmail.com', '123.123.123.123')
    end

    it 'is not equal to a host with a different IP' do
      Ghost::Host.new('google.com', '123.123.123.123').should_not ==
        Ghost::Host.new('google.com', '222.222.222.222')
    end
  end
end
