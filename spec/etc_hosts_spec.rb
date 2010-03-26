require 'ghost/linux-host'

$hosts_file   = File.expand_path(File.join(File.dirname(__FILE__), "etc_hosts"))

describe Host do
  before(:all) do
    class Host
      @@hosts_file = $hosts_file
    end
  end
  before { `touch #{$hosts_file.inspect}` }
  after  { `rm -f #{$hosts_file.inspect}` }
  
  it "has an IP" do
    hostname = 'ghost-test-hostname.local'

    Host.add(hostname)
    host = Host.list.first
    host.ip.should eql('127.0.0.1')

    Host.empty!

    ip = '169.254.23.121'
    host = Host.add(hostname, ip)
    host.ip.should eql(ip)
  end

  it "has a hostname" do
    hostname = 'ghost-test-hostname.local'

    Host.add(hostname)
    host = Host.list.first
    host.hostname.should eql(hostname)

    Host.empty!

    ip = '169.254.23.121'
    Host.add(hostname, ip)
    host.hostname.should eql(hostname)
  end
  
  describe ".list" do
    it "returns an array" do
      Host.list.should be_instance_of(Array)
    end

    it "contains instances of Host" do
      Host.add('ghost-test-hostname.local')
      Host.list.first.should be_instance_of(Host)
    end
    
    it "gets all hosts on a single /etc/hosts line" do
      example = "127.0.0.1\tproject_a.local\t\t\tproject_b.local   project_c.local"
      File.open($hosts_file, 'w') {|f| f << example}
      hosts = Host.list
      hosts.should have(3).items
      hosts.map{|h|h.ip}.uniq.should == ['127.0.0.1']
      hosts.map{|h|h.host}.sort.should == %w[project_a.local project_b.local project_c.local]
      Host.add("project_d.local")
      Host.list.should have(4).items
    end
  end
  
  describe "#to_s" do
    it "returns hostname" do
      hostname = 'ghost-test-hostname.local'

      Host.add(hostname)
      host = Host.list.first
      host.to_s.should eql(hostname)
    end
  end

  describe "finder methods" do
    before do
      Host.add('abc.local')
      Host.add('def.local')
      Host.add('efg.local', '10.2.2.4')
    end

    it "returns valid Host when searching for host name" do
      Host.find_by_host('abc.local').should be_instance_of(Host)
    end
  end

  describe ".add" do
    it "returns Host object when passed hostname" do
      Host.add('ghost-test-hostname.local').should be_instance_of(Host)
    end

    it "returns Host object when passed hostname" do
      Host.add('ghost-test-hostname.local', '10.0.0.2').should be_instance_of(Host)
    end

    it "raises error if hostname already exists and not add a duplicate" do
      Host.empty!
      Host.add('ghost-test-hostname.local')
      lambda { Host.add('ghost-test-hostname.local') }.should raise_error
      Host.list.should have(1).thing
    end

    it "overwrites existing hostname if forced" do
      hostname = 'ghost-test-hostname.local'

      Host.empty!
      Host.add(hostname)

      Host.list.first.hostname.should eql(hostname)
      Host.list.first.ip.should eql('127.0.0.1')

      Host.add(hostname, '10.0.0.1', true)
      Host.list.first.hostname.should eql(hostname)
      Host.list.first.ip.should eql('10.0.0.1')

      Host.list.should have(1).thing
    end
    
    it "should add a hostname using second hostname's ip" do
      hostname = 'ghost-test-hostname.local'
      alias_hostname = 'ghost-test-alias-hostname.local'

      Host.empty!

      Host.add(hostname)
      Host.add(alias_hostname, hostname)

      Host.list.last.ip.should eql(Host.list.first.ip)
    end

    it "should raise SocketError if it can't find hostname's ip" do
      Host.empty!
      lambda { Host.add('ghost-test-alias-hostname.google', 'google') }.should raise_error(SocketError)
    end
  end

  describe ".empty!" do
    it "empties the hostnames" do
      Host.add('ghost-test-hostname.local') # add a hostname to be sure
      Host.empty!
      Host.list.should have(0).things
    end
  end

  describe ".delete_matching" do
    it "deletes matching hostnames" do
      keep = 'ghost-test-hostname-keep.local'
      Host.add(keep)
      Host.add('ghost-test-hostname-match1.local')
      Host.add('ghost-test-hostname-match2.local')
      Host.delete_matching('match')
      Host.list.should have(1).thing
      Host.list.first.hostname.should eql(keep)
    end
  end
end
