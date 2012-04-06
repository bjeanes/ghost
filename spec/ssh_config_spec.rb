require 'ghost/ssh_config'

$ssh_config_template = File.expand_path(File.join(File.dirname(__FILE__), "ssh_config_template"))
$ssh_config_file     = File.expand_path(File.join(File.dirname(__FILE__), "ssh_config"))

describe Ghost::SshConfig do
  before(:all) do
    class Ghost::SshConfig
      @@ssh_config = $ssh_config_file
    end
  end
  before { `cp #{$ssh_config_template.inspect} #{$ssh_config_file.inspect}` }
  after  { `rm -f #{$ssh_config_file.inspect}` }

  subject do
    Ghost::SshConfig
  end

  it "has an Host" do
    subject.empty!

    host = "miami-b01"
    hostname = "192.168.227.128"
    user = "root"
    port = "389"

    subject.add(
      :host => host,
      :hostname => hostname,
      :user => user,
      :port => port)

    config = subject.list.first
    config.host.should eql(host)
    config.hostname.should eql(hostname)
    config.user.should eql(user)
    config.port.should eql(port)
  end

  describe '#list' do
    it "returns an array" do
      subject.list.should be_instance_of(Array)
    end

    it "contains instances of Ghost::SshConfig" do
      subject.empty!
      subject.add(
        :host => "miami-b01",
        :hostname => "192.168.227.128",
        :user => "root",
        :port => "39")

      config = subject.list

      (config = subject.list.first).should be_instance_of(Ghost::SshConfig)

      config.host.should eql("miami-b01")
      config.hostname.should eql("192.168.227.128")
      config.user.should eql("root")
      config.port.should eql("39")
    end

    it "parses the .ssh/config format" do
      configs = Ghost::SshConfig.list
      configs.should have(3).items

      configs[0].host.should eql("example1")
      configs[0].hostname.should eql("192.168.227.128")
      configs[0].user.should eql("root")

      configs[1].host.should eql("example2")
      configs[1].hostname.should eql("example2.webbynode.com")
      configs[1].user.should eql("root")
      configs[1].port.should eql("2022")

      configs[2].host.should eql("example3")
      configs[2].hostname.should eql("10.0.0.1")
    end
  end
end
