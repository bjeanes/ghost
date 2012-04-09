require 'ghost/linux-host'

$hosts_file   = File.expand_path(File.join(File.dirname(__FILE__), "etc_hosts"))

describe Ghost::Host do
  before(:all) do
    class Ghost::Host
      @@hosts_file = $hosts_file
    end
  end
  before { `touch #{$hosts_file.inspect}` }
  after  { `rm -f #{$hosts_file.inspect}` }

  it "has an IP" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.add(hostname)
    host = Ghost::Host.list.first
    host.ip.should eql('127.0.0.1')

    Ghost::Host.empty!

    ip = '169.254.23.121'
    host = Ghost::Host.add(hostname, ip)
    host.ip.should eql(ip)
  end

  it "has a hostname" do
    hostname = 'ghost-test-hostname.local'

    Ghost::Host.add(hostname)
    host = Ghost::Host.list.first
    host.hostname.should eql(hostname)

    Ghost::Host.empty!

    ip = '169.254.23.121'
    Ghost::Host.add(hostname, ip)
    host.hostname.should eql(hostname)
  end

  describe ".list" do
    it "returns an array" do
      Ghost::Host.list.should be_instance_of(Array)
    end

    it "contains instances of Ghost::Host" do
      Ghost::Host.add('ghost-test-hostname.local')
      Ghost::Host.list.first.should be_instance_of(Ghost::Host)
    end

    it "gets all hosts on a single /etc/hosts line" do
      example = <<-EoEx
              127.0.0.1      localhost.localdomain
              # ghost start
                 123.123.123.1     project_a.local\t\tproject_b.local   project_c.local
                 127.0.0.1         local.bb
              # ghost end
      EoEx
      File.open($hosts_file, 'w') {|f| f << example.gsub!(/^\s*/, '')}
      hosts = Ghost::Host.list
      hosts.should have(4).items
      hosts.map{|h|h.ip}.uniq.sort.should == ['123.123.123.1', '127.0.0.1']
      hosts.map{|h|h.host}.sort.should == %w[local.bb project_a.local project_b.local project_c.local]

      Ghost::Host.add("project_d.local")
      Ghost::Host.list.should have(5).items
    end
  end


  it "does not change hosts files outside of control tokens" do
    f = File.open($hosts_file, 'w')
    f.write "10.0.0.23 adserver.example.com\n"
    f.close
    hosts = Ghost::Host.list
    hosts.should have(0).items

    hostname = "ghost-test-hostname-b.local"
    Ghost::Host.add(hostname)
    Ghost::Host.list.should have(1).items

    hostsfile = File.read($hosts_file)
    hostsfile.should =~ /^10.0.0.23 adserver.example.com\n/
  end

  it "adds control tokens to untouched hosts files" do
    f = File.open($hosts_file, 'w')
    f.write "10.0.0.23 adserver.example.com\n"
    f.close
    hostname = "ghost-test-hostname-b.local"
    ip = '123.45.67.89'
    Ghost::Host.add(hostname, ip)

    hostsfile = File.read($hosts_file)
    hostsfile.should =~ /# ghost start\n#{ip}\s+#{hostname}\n# ghost end/
  end

  describe "#to_s" do
    it "returns hostname" do
      hostname = 'ghost-test-hostname.local'

      Ghost::Host.add(hostname)
      host = Ghost::Host.list.first
      host.to_s.should eql(hostname)
    end
  end

  describe "finder methods" do
    before do
      Ghost::Host.add('abc.local')
      Ghost::Host.add('def.local')
      Ghost::Host.add('efg.local', '10.2.2.4')
    end

    it "returns valid Ghost::Host when searching for host name" do
      Ghost::Host.find_by_host('abc.local').should be_instance_of(Ghost::Host)
    end
  end

  describe ".add" do
    it "returns Ghost::Host object when passed hostname" do
      Ghost::Host.add('ghost-test-hostname.local').should be_instance_of(Ghost::Host)
    end

    it "returns Ghost::Host object when passed hostname" do
      Ghost::Host.add('ghost-test-hostname.local', '10.0.0.2').should be_instance_of(Ghost::Host)
    end

    it "raises error if hostname already exists and not add a duplicate" do
      Ghost::Host.empty!
      Ghost::Host.add('ghost-test-hostname.local')
      lambda { Ghost::Host.add('ghost-test-hostname.local') }.should raise_error
      Ghost::Host.list.should have(1).thing
    end

    it "overwrites existing hostname if forced" do
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

  describe ".empty!" do
    it "empties the hostnames" do
      Ghost::Host.add('ghost-test-hostname.local') # add a hostname to be sure
      Ghost::Host.empty!
      Ghost::Host.list.should have(0).things
    end
  end

  describe ".delete_matching" do
    it "deletes matching hostnames" do
      keep = 'ghost-test-hostname-keep.local'
      Ghost::Host.add(keep)
      Ghost::Host.add('ghost-test-hostname-match1.local')
      Ghost::Host.add('ghost-test-hostname-match2.local')
      Ghost::Host.delete_matching('match')
      Ghost::Host.list.should have(1).thing
      Ghost::Host.list.first.hostname.should eql(keep)
    end
  end
end
