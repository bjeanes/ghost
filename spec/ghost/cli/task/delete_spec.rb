require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
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
end
