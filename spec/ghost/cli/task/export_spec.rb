require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  describe "export" do
    it "outputs all hosts one-per-line in hosts file format" do
      store.add Ghost::Host.new("gist.github.com", "10.0.0.1")
      store.add Ghost::Host.new("google.com", "192.168.1.10")

      ghost("export").should == <<-EOE.unindent
        10.0.0.1 gist.github.com
        192.168.1.10 google.com
        EOE
    end
  end
end
