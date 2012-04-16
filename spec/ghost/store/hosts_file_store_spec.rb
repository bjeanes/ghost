require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")
require 'ghost/store/hosts_file_store'

require 'ostruct'

describe Ghost::Store::HostsFileStore do
  subject     { store }

  let(:store) { described_class.new(file) }
  let(:file)  { StringIO.new }
  let(:contents) do
    <<-EOF.gsub(/^\s+/,'')
    127.0.0.1 localhost localhost.localdomain
    EOF
  end

  before do
    file.write(contents)
    file.rewind
  end

  describe "#all" do
    context 'with no ghost-managed hosts in the file' do
      it 'returns no hosts' do
        store.all.should == []
      end
    end
  end

  describe "#find"

  describe "#add" do
    let(:host) { OpenStruct.new(:name => "google.com", :ip => "127.0.0.1") }

    context 'with no ghost-managed hosts in the file' do
      it 'returns true' do
        store.add(host).should be_true
      end

      it 'adds the new host between delimeters' do
        store.add(host)
        file.read.should == <<-EOF.gsub(/^\s+/,'')
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
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when adding to an existing IP' do
        before { host.stub(:ip => '192.168.1.1') }

        it 'adds to existing entry between tokens, listing host names in alphabetical order' do
          store.add(host)
          file.read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            192.168.1.1 github.com google.com
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
          file.read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
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
      let(:host) { OpenStruct.new(:name => "localhost", :ip => "127.0.0.1") }

      it 'returns false' do
        store.delete(host).should be_false
      end

      it 'has no effect' do
        store.delete(host)
        file.read.should == contents
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
        file.read.should == contents
      end
    end
  end
end
