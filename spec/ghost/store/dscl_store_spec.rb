require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")
require 'ghost/store/dscl_store'

# TODO: Raise exception error when `dscl` doesn't have sufficient privileges
describe Ghost::Store::DsclStore do
  let(:store) { Ghost::Store::DsclStore.new }
  let(:cmd)   { Ghost::Store::DsclStore::Dscl }

  before do
    cmd.stub(:list => [])
    cmd.stub(:read => nil)
    cmd.stub(:create => true)
    cmd.stub(:delete => true)
  end

  let(:dscl_foo_com) do
    <<-EOF.unindent
    AppleMetaNodeLocation: /Local/Default
    GeneratedUID: 7FE20A09-21B5-42C5-9E8C-E64999BD20E2
    IPAddress: 123.123.123.123
    RecordName: foo.com
    RecordType: dsRecTypeStandard:Hosts
    EOF
  end

  let(:dscl_bar_com) do
    <<-EOF.unindent
    AppleMetaNodeLocation: /Local/Default
    GeneratedUID: 15286594-C5F1-4508-BAB0-98B96D424657
    IPAddress: 127.0.0.1
    RecordName: bar.com
    RecordType: dsRecTypeStandard:Hosts
    EOF
  end

  describe "#all" do
    it 'returns an empty array when no hosts are in the store' do
      store.all.should == []
    end

    it 'returns an array of Ghost::Host entries for each host in the store' do
      cmd.stub(:list).and_return([dscl_foo_com, dscl_bar_com])
      store.all.should == [
        Ghost::Host.new('foo.com', '123.123.123.123'),
        Ghost::Host.new('bar.com', '127.0.0.1')
      ]
    end
  end

  describe "#find" do
    it 'finds hosts matching a regex' do
      cmd.stub(:list).and_return([dscl_foo_com, dscl_bar_com])
      store.find(/.*/).should == store.all
      store.find(/f/).should == [Ghost::Host.new('foo.com', '123.123.123.123')]
    end
  end

  describe "#add" do
    let(:host) { Ghost::Host.new('foo.com', '123.123.123.123') }

    it 'returns true' do
      store.add(host).should be_true
    end

    # In order to make this run off OS X and without root, have to use an
    # expectation... I think?
    it 'adds the host' do
      cmd.should_receive(:create).with('localhost', 'foo.com', '123.123.123.123')
      store.add(host)
    end
  end

  describe "#delete" do
    before do
      store.stub(:all).and_return [
        Ghost::Host.new('foo.com', '127.0.0.1'),
        Ghost::Host.new('fo.com', '127.0.0.1'),
        Ghost::Host.new('fooo.com', '127.0.0.2')
      ]
    end

    context 'using a Ghost::Host to identify host' do
      context 'and the IP does not match an entry' do
        let(:host) { Ghost::Host.new("foo.com", "127.0.0.2") }

        it 'returns empty array' do
          store.delete(host).should == []
        end

        it 'has no effect' do
          store.delete(host)
          cmd.should_not_receive(:delete)
        end
      end

      context 'and the IP matches an entry' do
        let(:host) { Ghost::Host.new("foo.com", "127.0.0.1") }

        it 'returns array of deleted hosts' do
          store.delete(host).should == [host]
        end

        # In order to make this run off OS X and without root, have to use an
        # expectation... I think?
        it 'deletes the host' do
          cmd.should_receive(:delete).with('localhost', 'foo.com')
          store.delete(host)
        end
      end
    end

    context 'using a regex to identify hosts' do
      let(:host) { /fo*\.com/ }

      it 'returns array of removed hosts' do
        store.delete(host).should == [
          Ghost::Host.new('fo.com',   '127.0.0.1'),
          Ghost::Host.new('foo.com',  '127.0.0.1'),
          Ghost::Host.new('fooo.com', '127.0.0.2')
        ]
      end

      it 'deletes the hosts' do
        cmd.should_receive(:delete).with('localhost', 'fo.com')
        cmd.should_receive(:delete).with('localhost', 'foo.com')
        cmd.should_receive(:delete).with('localhost', 'fooo.com')
        store.delete(host)
      end
    end

    context 'using a string to identify host' do
      let(:host) { "foo.com" }

      it 'returns array of removed hosts' do
        store.delete(host).should == [Ghost::Host.new('foo.com', '127.0.0.1')]
      end

      it 'removes the host from the file' do
        cmd.should_receive(:delete).with('localhost', 'foo.com')
        store.delete(host)
      end
    end
  end

  describe "#empty"
end
