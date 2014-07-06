require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")
require 'ghost/store/hosts_file_store'

require 'tmpdir'

describe Ghost::Store::HostsFileStore do
  def write(content)
    File.open(file_path, 'w') { |f| f.write(content) }
  end

  def read
    File.read(file_path)
  end

  def no_write
    File.any_instance.stub(:reopen).with(anything, /[aw]/).and_raise("no writing!")
    File.any_instance.stub(:puts).and_raise("no writing!")
    File.any_instance.stub(:print).and_raise("no writing!")
    File.any_instance.stub(:write).and_raise("no writing!")
    File.any_instance.stub(:<<).and_raise("no writing!")
    File.any_instance.stub(:flush).and_raise("no writing!")
  end

  subject { store }

  let(:file_path) { File.join(Dir.tmpdir, "etc_hosts.#{Process.pid}.#{rand(9999)}") }
  let(:store)     { described_class.new(section_name: 'ghost', path: file_path) }
  let(:contents) do
    <<-EOF.unindent
    127.0.0.1 localhost localhost.localdomain
    EOF
  end

  before { write(contents) }

  it 'manages the default file of /etc/hosts when no file path is provided' do
    previous_hosts_location = described_class::DEFAULT_FILE
    described_class::DEFAULT_FILE = "hosts_location"
    described_class.new(section_name: 'ghost').path.should == "hosts_location"
    described_class::DEFAULT_FILE = previous_hosts_location
  end

  it 'manages the file at the provided path when given' do
    described_class.new(section_name: 'ghost', path: 'xyz').path.should == 'xyz'
  end

  describe 'initialize' do
    it 'accepts section name in option' do
      store = described_class.new(section_name: 'spook')
      store.section_name.should eq 'spook'
    end

    it 'can only set section name once' do
      store = described_class.new(path: file_path, section_name: 'spook')
      store.section_name.should eq 'spook'
      -> {
        store.section_name = 'phantom'
      }.should raise_error(RuntimeError)
      store.section_name.should eq 'spook'
    end
  end

  describe 'custom section name' do
    let(:host) { Ghost::Host.new("google.com", "127.0.0.1") }

    it 'uses custom section name in comment' do
      store = described_class.new(path: file_path, section_name: 'spook')
      store.add(host)
      read.should == <<-EOF.gsub(/^\s+/,'')
        127.0.0.1 localhost localhost.localdomain
        # spook start
        127.0.0.1 google.com
        # spook end
      EOF
    end

    it 'co-exists with other section' do
      store = described_class.new(path: file_path, section_name: 'phantom')
      store.add(host)
      read.should == <<-EOF.gsub(/^\s+/,'')
        127.0.0.1 localhost localhost.localdomain
        # phantom start
        127.0.0.1 google.com
        # phantom end
      EOF

      store = described_class.new(path: file_path, section_name: 'spook')
      store.add(host)
      read.should == <<-EOF.gsub(/^\s+/,'')
        127.0.0.1 localhost localhost.localdomain
        # phantom start
        127.0.0.1 google.com
        # phantom end
        # spook start
        127.0.0.1 google.com
        # spook end
      EOF
    end
  end

  describe "#all" do
    context 'with no ghost-managed hosts in the file' do
      it 'returns no hosts' do
        store.all.should == []
      end
    end

    context 'with some ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
        127.0.0.1 localhost localhost.localdomain
        # ghost start
        1.2.3.4 bjeanes.com
        2.3.4.5 my-app.com subdomain.my-app.com
        # ghost end
        EOF
      end

      it 'returns an array with one Ghost::Host per ghost-managed host in the hosts file' do
        store.all.should == [
          Ghost::Host.new('bjeanes.com', '1.2.3.4'),
          Ghost::Host.new('my-app.com', '2.3.4.5'),
          Ghost::Host.new('subdomain.my-app.com', '2.3.4.5')
        ]
      end

      it "shouldn't write to the file" do
        no_write
        store.all
      end
    end
  end

  describe "#find" do
    let(:contents) do
      <<-EOF.gsub(/^\s+/,'')
      # ghost start
      1.2.3.4 bjeanes.com
      2.3.4.5 my-app.com subdomain.my-app.com
      # ghost end
      EOF
    end

    it "finds hosts matching a regex" do
      store.find(/.*/).should == store.all
      store.find(/my-app\.com$/i).should == [
        Ghost::Host.new('my-app.com', '2.3.4.5'),
        Ghost::Host.new('subdomain.my-app.com', '2.3.4.5')
      ]
    end
  end

  describe "#add" do
    let(:host) { Ghost::Host.new("google.com", "127.0.0.1") }

    context 'with no ghost-managed hosts in the file' do
      it 'returns true' do
        store.add(host).should be_true
      end

      it 'adds the new host between delimeters' do
        store.add(host)
        read.should == <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          # ghost end
        EOF
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          1.2.3.4 a.com b.com c.com d.com e.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when adding to an existing IP' do
        before { host.ip = '192.168.1.1' }

        it 'adds to existing entry between tokens, listing host names in alphabetical order' do
          store.add(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            1.2.3.4 a.com b.com c.com d.com e.com
            192.168.1.1 github.com google.com
            # ghost end
          EOF
        end

        it 'limits hosts per line to 5' do
          host = Ghost::Host.new('f.com', '1.2.3.4')

          store.add(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            1.2.3.4 a.com b.com c.com d.com e.com
            1.2.3.4 f.com
            192.168.1.1 github.com
            # ghost end
          EOF
        end

        it 'returns true' do
          store.add(host).should be_true
        end
      end

      context 'when adding a new IP' do
        it 'adds new entry between tokens, in numerical order' do
          store.add(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            1.2.3.4 a.com b.com c.com d.com e.com
            127.0.0.1 google.com
            192.168.1.1 github.com
            # ghost end
          EOF
        end

        it 'returns true' do
          store.add(host).should be_true
        end
      end
    end
  end

  describe "#delete" do
    context 'with no ghost-managed hosts in the file' do
      let(:host) { Ghost::Host.new("localhost", "127.0.0.1") }

      it 'returns empty array' do
        store.delete(host).should == []
      end

      it 'has no effect' do
        store.delete(host)
        read.should == contents
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          127.0.0.2 gooogle.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when deleting one of the ghost entries' do
        context 'using a Ghost::Host to identify host' do
          context 'and the IP does not match an entry' do
            let(:host) { Ghost::Host.new("google.com", "127.0.0.2") }

            it 'returns empty array' do
              store.delete(host).should == []
            end

            it 'has no effect' do
              store.delete(host)
              read.should == contents
            end
          end

          context 'and the IP matches an entry' do
            let(:host) { Ghost::Host.new("google.com", "127.0.0.1") }

            it 'returns array of removed hosts' do
              store.delete(host).should == [Ghost::Host.new('google.com', '127.0.0.1')]
            end

            it 'removes the host from the file' do
              store.delete(host)
              read.should == <<-EOF.gsub(/^\s+/,'')
                127.0.0.1 localhost localhost.localdomain
                # ghost start
                127.0.0.2 gooogle.com
                192.168.1.1 github.com
                # ghost end
              EOF
            end
          end
        end

        context 'using a regex to identify hosts' do
          let(:host) { /go*gle\.com/ }

          it 'returns array of removed hosts' do
            store.delete(host).should == [
              Ghost::Host.new('google.com',  '127.0.0.1'),
              Ghost::Host.new('gooogle.com', '127.0.0.2')
            ]
          end

          it 'removes the host from the file' do
            store.delete(host)
            read.should == <<-EOF.gsub(/^\s+/,'')
              127.0.0.1 localhost localhost.localdomain
              # ghost start
              192.168.1.1 github.com
              # ghost end
            EOF
          end
        end

        context 'using a string to identify host' do
          let(:host) { "google.com" }

          it 'returns array of removed hosts' do
            store.delete(host).should == [Ghost::Host.new('google.com', '127.0.0.1')]
          end

          it 'removes the host from the file' do
            store.delete(host)
            read.should == <<-EOF.gsub(/^\s+/,'')
              127.0.0.1 localhost localhost.localdomain
              # ghost start
              127.0.0.2 gooogle.com
              192.168.1.1 github.com
              # ghost end
            EOF
          end
        end

        context 'using a partial string to identify host' do
          let(:host) { "googl" }

          it 'returns empty array' do
            store.delete(host).should == []
          end

          it 'does not modify the host file' do
            store.delete(host)
            read.should == contents
          end
        end
      end

      context 'when trying to delete a non-ghost entry' do
        let(:host) { Ghost::Host.new("localhost") }

        it 'returns false' do
          store.delete(host).should == []
        end

        it 'has no effect' do
          store.delete(host)
          read.should == contents
        end
      end
    end
  end

  describe "#set" do
    let(:host) { Ghost::Host.new("github.com", "127.0.0.1") }

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          192.168.1.1 github.com
          192.168.1.2 github.com
          # ghost end
        EOF
      end

      context 'when setting the host to an IP' do
        it 'replaces all instances of that hostname with a single entry for that IP' do
          store.set(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            127.0.0.1 github.com
            # ghost end
          EOF
        end

        it 'returns true' do
          store.set(host).should be_true
        end
      end
    end
  end

  describe "#purge" do
    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          127.0.0.2 gooogle.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when purging one of the ghost entries' do
        context 'using a Ghost::Host to identify host' do
          context 'and the IP does not match an entry' do
            let(:host) { Ghost::Host.new("google.com", "127.0.0.2") }

            it 'returns array of removed hosts' do
              store.purge(host).should == [Ghost::Host.new('google.com', '127.0.0.1')]
            end

            it 'removes the host from the file' do
              store.purge(host)
              read.should == <<-EOF.gsub(/^\s+/,'')
                127.0.0.1 localhost localhost.localdomain
                # ghost start
                127.0.0.2 gooogle.com
                192.168.1.1 github.com
                # ghost end
              EOF
            end
          end

          context 'and the IP matches an entry' do
            let(:host) { Ghost::Host.new("google.com", "127.0.0.1") }

            it 'returns array of removed hosts' do
              store.purge(host).should == [Ghost::Host.new('google.com', '127.0.0.1')]
            end

            it 'removes the host from the file' do
              store.purge(host)
              read.should == <<-EOF.gsub(/^\s+/,'')
                127.0.0.1 localhost localhost.localdomain
                # ghost start
                127.0.0.2 gooogle.com
                192.168.1.1 github.com
                # ghost end
              EOF
            end
          end
        end
      end
    end
  end

  describe "#empty" do
    context 'with no ghost-managed hosts in the file' do
      it 'returns false' do
        store.empty.should be_false
      end

      it 'has no effect' do
        store.empty
        read.should == contents
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when deleting one of the ghost entries' do
        it 'returns true' do
          store.empty.should be_true
        end

        it 'removes the host from the file' do
          store.empty
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
          EOF
        end
      end
    end
  end
end
