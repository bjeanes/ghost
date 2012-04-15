require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli do
  def ghost(args)
    out = StringIO.new
    Ghost::Cli.new(args.split(/\s+/), out).parse
    out.rewind
    out.read.chomp
  rescue SystemExit
    out.rewind
    out.read.chomp
  end

  describe "environment configuration" # via GHOST_OPTS (see OptionParser#environment)

  describe "--version" do
    it "outputs the gem name and version" do
      ghost("--version").should == "ghost #{Ghost::VERSION}"
      ghost("-v").should == "ghost #{Ghost::VERSION}"
    end
  end

  describe "add" do
    context "with a local hostname" do
      before     { Ghost::Host.stub(:new).with("my-app.local").and_return(host) }
      let(:host) { stub(:name => "my-app.local", :ip => "127.0.0.1") }

      it "adds the host pointing to 127.0.0.1" do
        Ghost::Host.should_receive(:add).with(host)
        ghost("add my-app.local")
      end

      it "outputs a summary of the operation" do
        Ghost::Host.stub(:add)
        ghost("add my-app.local").should == "  [Adding] my-app.local -> 127.0.0.1"
      end

      context "when an entry for that hostname already exists" do
        it "outputs an error message"
      end

      context "and an IP address" do
        before     { Ghost::Host.stub(:new).with("my-app.local", "192.168.1.1").and_return(host) }
        let(:host) { stub(:name => "my-app.local", :ip => "192.168.1.1") }

        it "adds the host pointing to the IP address" do
          Ghost::Host.should_receive(:add).with(host)
          ghost("add my-app.local 192.168.1.1")
        end

        it "outputs a summary of the operation" do
          Ghost::Host.stub(:add)
          ghost("add my-app.local 192.168.1.1").should == "  [Adding] my-app.local -> 192.168.1.1"
        end
      end

      context "and a remote hostname" do
        before     { Ghost::Host.stub(:new).with("my-app.local", "google.com").and_return(host) }
        let(:host) { stub(:name => "my-app.local", :ip => "74.125.225.99") }

        it "adds the host pointing to the IP address" do
          Ghost::Host.should_receive(:add).with(host)
          ghost("add my-app.local google.com")
        end

        it "outputs a summary of the operation" do
          Ghost::Host.stub(:add)
          ghost("add my-app.local google.com").should == "  [Adding] my-app.local -> 74.125.225.99"
        end

        context "when the remote hostname can not be resolved" do
          before { Ghost::Host.stub(:new).and_raise(Ghost::NotResolvable) }
          it "outputs an error message"
        end
      end
    end
  end

  describe "modify"
  describe "delete"
  describe "delete_matching"
  describe "list" do
    before do
      Ghost::Host.stub(:list => [
        Ghost::Host.new("gist.github.com", "10.0.0.1"),
        Ghost::Host.new("google.com", "192.168.1.10")
      ])
    end

    context "with no filtering parameter" do
      it "outputs all hostnames" do
        ghost("list").should == %"
          Listing 2 host(s):
            gist.github.com -> 10.0.0.1
                 google.com -> 192.168.1.10
        ".gsub(/^\s{8}/,'').strip.chomp
      end
    end

    context "with a filtering parameter" do
      it "outputs entries whose hostname or IP match the filter"
    end
  end
  describe "empty"
  describe "export"
  describe "import"
end
