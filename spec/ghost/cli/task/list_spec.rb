require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  describe "list" do
    before do
      store.add Ghost::Host.new("gist.github.com", "10.0.0.1")
      store.add Ghost::Host.new("google.com", "192.168.1.10")
    end

    context "with no filtering parameter" do
      it "outputs all hostnames" do
        ghost("list").should == <<-EOF.unindent
          Listing 2 host(s):
            gist.github.com -> 10.0.0.1
                 google.com -> 192.168.1.10
          EOF
      end
    end

    context "with a filtering parameter" do
      before do
        store.empty
        store.add Ghost::Host.new("google.com", "10.0.0.1")
        store.add Ghost::Host.new("google.co.uk", "192.168.1.10")
        store.add Ghost::Host.new("gmail.com")
      end

      context 'that is a regex' do
        it "outputs entries whose hostname or IP match the filter" do
          ghost("list /\.com$/").should == <<-EOF.unindent
            Listing 2 host(s):
              google.com -> 10.0.0.1
               gmail.com -> 127.0.0.1
            EOF
        end
      end

      context 'that is a string' do
        it "outputs entries whose hostname or IP match the filter" do
          ghost("list google").should == <<-EOF.unindent
            Listing 2 host(s):
                google.com -> 10.0.0.1
              google.co.uk -> 192.168.1.10
            EOF
        end
      end
    end
  end
end
