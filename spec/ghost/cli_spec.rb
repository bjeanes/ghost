require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/cli'

# TODO: test exit statuses
describe Ghost::Cli, :type => :cli do
  context 'writable operations with out proper permissions' do
    it 'outputs a message telling user to escalate permissions' do
      store.stub(:add).and_raise(Errno::EACCES)

      ghost("add domain.com").should == "Insufficient privileges. Try using `sudo` or running as root.\n"
    end
  end

  describe "environment configuration" # via GHOST_OPTS (see OptionParser#environment)

  describe "--version" do
    it "outputs the gem name and version" do
      ghost("--version").should == "ghost #{Ghost::VERSION}\n"
      ghost("-v").should == "ghost #{Ghost::VERSION}\n"
    end
  end
end
