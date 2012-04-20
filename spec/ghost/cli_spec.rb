require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/cli'

require 'tempfile'

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

  before { Ghost.store = store }
  let(:store) { mock }

  describe "environment configuration" # via GHOST_OPTS (see OptionParser#environment)

  describe "--version" do
    it "outputs the gem name and version" do
      ghost("--version").should == "ghost #{Ghost::VERSION}"
      ghost("-v").should == "ghost #{Ghost::VERSION}"
    end
  end

  describe "add" do
    context "with a local hostname" do
      let(:host) { Ghost::Host.new("my-app.local") }

      it "adds the host pointing to 127.0.0.1" do
        store.should_receive(:add).with(host)
        ghost("add my-app.local")
      end

      it "outputs a summary of the operation" do
        store.stub(:add)
        ghost("add my-app.local").should == "[Adding] my-app.local -> 127.0.0.1"
      end

      context "when an entry for that hostname already exists" do
        it "outputs an error message"
      end

      context "and an IP address" do
        let(:host) { Ghost::Host.new("my-app.local", "192.168.1.1") }

        it "adds the host pointing to the IP address" do
          store.should_receive(:add).with(host)
          ghost("add my-app.local 192.168.1.1")
        end

        it "outputs a summary of the operation" do
          store.stub(:add)
          ghost("add my-app.local 192.168.1.1").should == "[Adding] my-app.local -> 192.168.1.1"
        end
      end

      context "and a remote hostname" do
        before     { Ghost::Host.stub(:new).with("my-app.local", "google.com").and_return(host) }
        let(:host) { stub(:name => "my-app.local", :ip => "74.125.225.99") }

        it "adds the host pointing to the IP address" do
          store.should_receive(:add).with(host)
          ghost("add my-app.local google.com")
        end

        it "outputs a summary of the operation" do
          store.stub(:add)
          ghost("add my-app.local google.com").should == "[Adding] my-app.local -> 74.125.225.99"
        end

        context "when the remote hostname can not be resolved" do
          before { Ghost::Host.stub(:new).and_raise(Ghost::NotResolvable) }
          it "outputs an error message"
        end
      end
    end
  end

  describe "modify" do
    it 'outputs deprecation warning' # TODO: remove in favor of 'add -f'
  end

  describe "delete_matching" do
    it 'outputs deprecation warning' # TODO: remove in favor of 'delete' with a pattern
  end

  describe "delete" do
    context 'with filtering pattern' do
      it 'deletes only entries whose hostname matches the pattern' do
        store.should_receive(:delete).with(/fo*.com?/i)
        ghost("delete /fo*.com?/")
      end
    end

    context 'without filtering pattern' do
      it 'deletes the specified hostname' do
        store.should_receive(:delete).with('foo.com')
        ghost("delete foo.com")
      end
    end
  end

  describe "list" do
    before do
      store.stub(:all => [
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
        ".gsub(/^\s{10}/,'').strip.chomp
      end
    end

    context "with a filtering parameter" do
      it "outputs entries whose hostname or IP match the filter"
    end
  end

  describe "empty" do
    it 'empties the list of hosts' do
      store.should_receive(:empty)
      ghost("empty")
    end

    it 'outputs a summary of the operation' do
      store.stub(:empty)
      ghost("empty").should == "[Emptying] Done."
    end
  end

  describe "export" do
    it "outputs all hosts one-per-line in hosts file format" do
      store.stub(:all => [
        Ghost::Host.new("gist.github.com", "10.0.0.1"),
        Ghost::Host.new("google.com", "192.168.1.10")
      ])

      ghost("export").should == <<-EOE.gsub(/^\s+/,'').chomp
        10.0.0.1 gist.github.com
        192.168.1.10 google.com
        EOE
    end
  end
  describe "import" do
    context "with current export format" do
      let(:import) do
        <<-EOI.gsub(/^\s+/,'').chomp
        1.2.3.4 foo.com
        2.3.4.5 bar.com
        EOI
      end

      let(:foo_com) { stub(:name => 'foo.com', :ip => '1.2.3.4') }
      let(:bar_com) { stub(:name => 'bar.com', :ip => '2.3.4.5') }

      context 'with no file name'
      context 'with STDIN sudo file name (-)'

      context 'with a file name' do
        it 'adds each entry' do
          Ghost::Host.stub(:new).with(foo_com.name, foo_com.ip).and_return(foo_com)
          Ghost::Host.stub(:new).with(bar_com.name, bar_com.ip).and_return(bar_com)

          store.should_receive(:add).with(foo_com)
          store.should_receive(:add).with(bar_com)

          file = Tempfile.new('import')
          file.write(import)
          file.close

          ghost("import #{file.path}")
        end
      end

      context 'with multiple file names'

      context 'when an entry is already present' do
        context 'without the -f flag' do
          it 'skips the existing entries'
          it 'prints a warning about skipped entries'
        end

        context 'with the -f flag' do
          it 'overwrites the existing entries'
        end
      end

      context 'with multiple hosts per line' do
        let(:import) do
          <<-EOI.gsub(/^\s+/,'').chomp
          1.2.3.4 foo.com
          2.3.4.5 bar.com subdomain.bar.com
          EOI
        end
      end
    end
  end
end
