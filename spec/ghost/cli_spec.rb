require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/cli'

require 'fileutils'
require 'tempfile'
require 'tmpdir'

# TODO: test exit statuses
describe Ghost::Cli do
  def ghost(args)
    out = StringIO.new
    Ghost::Cli.new(out).parse(args.split(/\s+/))
    out.rewind
    out.read.chomp
  rescue SystemExit
    out.rewind
    out.read.chomp
  end

  let(:store_path) { File.join(Dir.tmpdir, "etc_hosts.#{Process.pid}.#{rand(9999)}") }
  let(:store)      { Ghost::Store::HostsFileStore.new(store_path) }

  before do
    FileUtils.touch(store_path)
    Ghost.store = store
  end

  describe "help" do
    let(:overview) do
      """
      USAGE: ghost <task> [<args>]

      The ghost tasks are:
        add        Add a host
        delete     Remove a ghost-managed host
        list       Show all (or a filtered) list of hosts
        import     Import hosts in /etc/hosts format
        export     Export all hosts in /etc/hosts format
        empty      Clear all ghost-managed hosts

      See 'ghost help <task>' for more information on a specific task.
      """.gsub(/^ {6}/,'').strip
    end

    it 'displays help overview when called with no args' do
      ghost("").should == overview
    end

    it 'displays help overview when help task is called with no arguments' do
      ghost("help").should == overview
    end
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
      let(:host) { Ghost::Host.new("my-app.local") }

      it "adds the host pointing to 127.0.0.1" do
        ghost("add my-app.local")
        store.all.should include(Ghost::Host.new("my-app.local", "127.0.0.1"))
      end

      it "outputs a summary of the operation" do
        ghost("add my-app.local").should == "[Adding] my-app.local -> 127.0.0.1"
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
          ghost("add my-app.local 192.168.1.1").should == "[Adding] my-app.local -> 192.168.1.1"
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
            "[Adding] my-app.local -> 74.125.225.99"
        end

        context "when the remote hostname can not be resolved" do
          before { Ghost::Host.stub(:new).and_raise(Ghost::Host::NotResolvable) }

          it "outputs an error message" do
            ghost("add my-app.local google.com").should == "Unable to resolve IP address for target host \"google.com\"."
          end
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
      store.add Ghost::Host.new("gist.github.com", "10.0.0.1")
      store.add Ghost::Host.new("google.com", "192.168.1.10")
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
      before do
        store.empty
        store.add Ghost::Host.new("google.com", "10.0.0.1")
        store.add Ghost::Host.new("google.co.uk", "192.168.1.10")
        store.add Ghost::Host.new("gmail.com")
      end

      context 'that is a regex' do
        it "outputs entries whose hostname or IP match the filter" do
          ghost("list /\.com$/").should == %"
            Listing 2 host(s):
              google.com -> 10.0.0.1
               gmail.com -> 127.0.0.1
            ".gsub(/^\s{12}/,'').strip.chomp
        end
      end

      context 'that is a string' do
        it "outputs entries whose hostname or IP match the filter" do
          ghost("list google").should == %"
            Listing 2 host(s):
                google.com -> 10.0.0.1
              google.co.uk -> 192.168.1.10
            ".gsub(/^\s{12}/,'').strip.chomp
        end
      end
    end
  end

  describe "empty" do
    before do
      store.add(Ghost::Host.new("xyz", "127.0.0.1"))
    end

    it 'empties the list of hosts' do
      ghost("empty")
      store.all.should be_empty
    end

    it 'outputs a summary of the operation' do
      ghost("empty").should == "[Emptying] Done."
    end
  end

  describe "export" do
    it "outputs all hosts one-per-line in hosts file format" do
      store.add Ghost::Host.new("gist.github.com", "10.0.0.1")
      store.add Ghost::Host.new("google.com", "192.168.1.10")

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

      let(:foo_com) { Ghost::Host.new('foo.com', '1.2.3.4') }
      let(:bar_com) { Ghost::Host.new('bar.com', '2.3.4.5') }

      context 'with no file name'
      context 'with STDIN pseudo file name (-)'

      context 'with a file name' do
        it 'adds each entry' do
          file = Tempfile.new('import')
          file.write(import)
          file.close

          ghost("import #{file.path}")

          store.all.should include(foo_com)
          store.all.should include(bar_com)
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
