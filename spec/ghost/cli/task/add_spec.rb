require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  # FIXME: these are petty silly tests to have. Find a nice way to check
  # that documentation is accessible and printable for all meaninful tests
  # but don't test actual contents...
  describe "help add" do
    specify do
      ghost("help add").should == <<-EOF.unindent
        Usage: ghost add <local host name> [<remote host name>|<IP address>]

        Add a host.

        If a second parameter is not provided, it defaults to 127.0.0.1

        Examples:
          ghost add my-localhost          # points to 127.0.0.1
          ghost add google.dev google.com # points to the IP of google.com
          ghost add router 192.168.1.1    # points to 192.168.1.1
        EOF
    end
  end

  describe "add" do
    context "with a local hostname" do
      let(:host) { Ghost::Host.new("my-app.local") }

      it "adds the host pointing to 127.0.0.1" do
        ghost("add my-app.local")
        store.all.should include(Ghost::Host.new("my-app.local", "127.0.0.1"))
      end

      it "outputs a summary of the operation" do
        ghost("add my-app.local").should == "[Adding] my-app.local -> 127.0.0.1\n"
      end

      context "when an entry for that hostname already exists" do
        it "outputs an error message"
      end

      context "and an IP address" do
        let(:host) { Ghost::Host.new("my-app.local", "192.168.1.1") }

        it "adds the host pointing to the IP address" do
          ghost("add my-app.local 192.168.1.1")
          store.all.should include(Ghost::Host.new("my-app.local", "192.168.1.1"))
        end

        it "outputs a summary of the operation" do
          ghost("add my-app.local 192.168.1.1").should == "[Adding] my-app.local -> 192.168.1.1\n"
        end
      end

      context "and a remote hostname" do
        # TODO: replace this stub once DNS resolution works
        let(:host) { Ghost::Host.new("my-app.local", "google.com") }
        before { Ghost::Host.any_instance.stub(:resolve_ip => "74.125.225.99") }

        it "adds the host pointing to the IP address" do
          ghost("add my-app.local google.com")
          store.all.should include(host)
        end

        it "outputs a summary of the operation" do
          ghost("add my-app.local google.com").should ==
            "[Adding] my-app.local -> 74.125.225.99\n"
        end

        context "when the remote hostname can not be resolved" do
          before { Ghost::Host.stub(:new).and_raise(Ghost::Host::NotResolvable) }

          it "outputs an error message" do
            ghost("add my-app.local google.com").should == "Unable to resolve IP address for target host \"google.com\".\n"
          end
        end
      end
    end
  end
end
