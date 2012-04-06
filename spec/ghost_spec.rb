require File.dirname(__FILE__) + '/spec_helper'
require 'ghost'

# Warning: these tests will delete all hostnames in the system. Please back them up first

Ghost::Host.empty!

describe Ghost::Host, ".list" do
  after(:each) { Ghost::Host.empty! }

  it "should return an array" do
    Ghost::Host.list.should be_instance_of(Array)
  end

  it "should contain instances of Ghost::Host" do
    Ghost::Host.add('ghost-test-hostname.local')
    Ghost::Host.list.first.should be_instance_of(Ghost::Host)
  end
end

describe Ghost::Host do
  after(:each) { Ghost::Host.empty! }

  it "should have an IP" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.add(hostname)
    host = Ghost::Host.list.first
    host.ip.should eql('127.0.0.1')

    Ghost::Host.empty!

    ip = '169.254.23.121'
    host = Ghost::Host.add(hostname, ip)
    host.ip.should eql(ip)
  end

  it "should have a hostname" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.add(hostname)
    host = Ghost::Host.list.first
    host.hostname.should eql(hostname)

    Ghost::Host.empty!

    ip = '169.254.23.121'
    Ghost::Host.add(hostname, ip)
    host.hostname.should eql(hostname)
  end

  it ".to_s should return hostname" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.add(hostname)
    host = Ghost::Host.list.first
    host.to_s.should eql(hostname)
  end
end

describe Ghost::Host, "finder methods" do
  after(:all) { Ghost::Host.empty! }
  before(:all) do
    Ghost::Host.add('abc.local')
    Ghost::Host.add('def.local')
    Ghost::Host.add('efg.local', '10.2.2.4')
  end

  it "should return valid Ghost::Host when searching for host name" do
    Ghost::Host.find_by_host('abc.local').should be_instance_of(Ghost::Host)
  end

end

describe Ghost::Host, ".add" do
  after(:each) { Ghost::Host.empty! }

  it "should return Ghost::Host object when passed hostname" do
    Ghost::Host.add('ghost-test-hostname.local').should be_instance_of(Ghost::Host)
  end

  it "should return Ghost::Host object when passed hostname" do
    Ghost::Host.add('ghost-test-hostname.local', '10.0.0.2').should be_instance_of(Ghost::Host)
  end

  it "should raise error if hostname already exists and not add a duplicate" do
    Ghost::Host.empty!
    Ghost::Host.add('ghost-test-hostname.local')
    lambda { Ghost::Host.add('ghost-test-hostname.local') }.should raise_error
    Ghost::Host.list.should have(1).thing
  end

  it "should overwrite existing hostname if forced" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.empty!
    Ghost::Host.add(hostname)

    Ghost::Host.list.first.hostname.should eql(hostname)
    Ghost::Host.list.first.ip.should eql('127.0.0.1')

    Ghost::Host.add(hostname, '10.0.0.1', true)
    Ghost::Host.list.first.hostname.should eql(hostname)
    Ghost::Host.list.first.ip.should eql('10.0.0.1')

    Ghost::Host.list.should have(1).thing
  end

  it "should add a hostname using second hostname's ip" do
    hostname = 'ghost-test-hostname.local'
    alias_hostname = 'ghost-test-alias-hostname.local'

    Ghost::Host.empty!

    Ghost::Host.add(hostname)
    Ghost::Host.add(alias_hostname, hostname)

    Ghost::Host.list.last.ip.should eql(Ghost::Host.list.first.ip)
  end

  it "should raise SocketError if it can't find hostname's ip" do
    Ghost::Host.empty!
    lambda { Ghost::Host.add('ghost-test-alias-hostname.google', 'google') }.should raise_error(SocketError)
  end
end

describe Ghost::Host, ".empty!" do
  it "should empty the hostnames" do
    Ghost::Host.add('ghost-test-hostname.local') # add a hostname to be sure
    Ghost::Host.empty!
    Ghost::Host.list.should have(0).things
  end
end

describe Ghost::Host, ".delete_matching" do
  it "should delete matching hostnames" do
    keep = 'ghost-test-hostname-keep.local'
    Ghost::Host.add(keep)
    Ghost::Host.add('ghost-test-hostname-match1.local')
    Ghost::Host.add('ghost-test-hostname-match2.local')
    Ghost::Host.delete_matching('match')
    Ghost::Host.list.should have(1).thing
    Ghost::Host.list.first.hostname.should eql(keep)
  end
end


describe Ghost::Host, ".backup and", Ghost::Host, ".restore" do
  it "should return a yaml file of all hosts and IPs when backing up"
  it "should empty the hosts and restore only the ones in given yaml"
end
