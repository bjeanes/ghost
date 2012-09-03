require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  describe "empty" do
    before do
      store.add(Ghost::Host.new("xyz", "127.0.0.1"))
    end

    it 'empties the list of hosts' do
      ghost("empty")
      store.all.should be_empty
    end

    it 'outputs a summary of the operation' do
      ghost("empty").should == "[Emptying] Done.\n"
    end
  end
end
