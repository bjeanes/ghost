require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")
require 'ghost/store/dscl_store'

describe Ghost::Store::DsclStore do
  let(:store) { Ghost.store = Ghost::Store::DsclStore.new }
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

  describe "#delete"
  describe "#add"
  describe "#delete"
  describe "#empty"
end
