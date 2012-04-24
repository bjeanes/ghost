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

  describe "help" do
    let(:overview) do
      <<-EOF.unindent
        USAGE: ghost <task> [<args>]

        The ghost tasks are:
          add        Add a host
          delete     Remove a ghost-managed host
          empty      Clear all ghost-managed hosts
          export     Export all hosts in /etc/hosts format
          import     Import hosts in /etc/hosts format
          list       Show all (or a filtered) list of hosts

        See 'ghost help <task>' for more information on a specific task.
      EOF
    end

    it 'displays help overview when called with no args' do
      ghost("").should == overview
    end

    it 'displays help overview when help task is called with no arguments' do
      ghost("help").should == overview
    end

    context "when no help text for a given topic is available" do
      it "prints out a message" do
        ghost("help missing").should == "No help for task 'missing'\n"
      end
    end

    # FIXME: these are petty silly tests to have. Find a nice way to check
    # that documentation is accessible and printable for all meaninful tests
    # but don't test actual contents...
    describe "add" do
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
  end

  describe "environment configuration" # via GHOST_OPTS (see OptionParser#environment)

  describe "--version" do
    it "outputs the gem name and version" do
      ghost("--version").should == "ghost #{Ghost::VERSION}\n"
      ghost("-v").should == "ghost #{Ghost::VERSION}\n"
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

  describe "import" do
    context "with current export format" do
      let(:import) do
        <<-EOI.unindent
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
          <<-EOI.unindent
          1.2.3.4 foo.com
          2.3.4.5 bar.com subdomain.bar.com
          EOI
        end
      end
    end
  end
end
