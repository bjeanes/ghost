require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/tokenized_file'

require 'tmpdir'
require 'fileutils'

describe Ghost::TokenizedFile do
  let(:file)           { File.open(file_path, 'r+') }
  let(:file_path)      { File.join(Dir.tmpdir, "tokenized_file.#{Process.pid}.#{rand(9999999)}") }
  let(:tokenized_file) { Ghost::TokenizedFile.new(file_path, start_token, end_token) }
  let(:start_token)    { "# start" }
  let(:end_token)      { "# end" }

  before { FileUtils.touch(file_path) }

  describe "#read" do
    context "with empty file" do
      it "returns empty string" do
        tokenized_file.read.should == ""
      end
    end

    context "with a non-empty file with no tokens" do
      before do
        file.write "hi there"
        file.close
      end

      it "returns empty string" do
        tokenized_file.read.should == ""
      end
    end

    context 'with a non-empty file with content between tokens' do
      before do
        file.write "#{start_token}\nline 1\nline 2\n#{end_token}"
        file.close
      end

      it "returns empty string" do
        tokenized_file.read.should == "line 1\nline 2\n"
      end
    end

    context 'with a non-empty file with empty tokens' do
      before do
        file.write "#{start_token}\n#{end_token}"
        file.flush
        file.rewind
      end

      it "returns empty string" do
        tokenized_file.read.should == ""
      end
    end
  end

  describe "#write" do
    context 'writing to a file with existing content' do
      context "with no tokens" do
        before do
          file.write "xyz"
          file.flush
          file.rewind
        end

        it "doesn't change file contents when writing nothing" do
          tokenized_file.write ""
          file.read.should == "xyz\n"
        end

        it "inserts appends new content to file between tokens" do
          tokenized_file.write "abc"
          file.read.should == "xyz\n#{start_token}\nabc\n#{end_token}\n"
        end
      end

      context "with empty tokens" do
        before do
          file.write "#{start_token}\n#{end_token}\nxyz"
          file.flush
          file.rewind
        end

        it "removes the token when writing an nothing" do
          tokenized_file.write ""
          file.read.should == "xyz\n"
        end

        it "adds content between the tokens when writing content" do
          tokenized_file.write "foo"
          file.read.should == "xyz\n#{start_token}\nfoo\n#{end_token}\n"
        end
      end

      context "with non-empty tokens" do
        before do
          file.write "#{start_token}\nfoo\n#{end_token}\nxyz"
          file.flush
          file.rewind
        end

        it "removes the token when writing an nothing" do
          tokenized_file.write ""
          file.read.should == "xyz\n"
        end

        it "replaces the content between the tokens when writing new content" do
          tokenized_file.write "bar"
          file.read.should == "xyz\n#{start_token}\nbar\n#{end_token}\n"
        end
      end
    end

    context "writing to an empty file" do
      context "when writing nothing" do
        it "writes nothing to the file" do
          tokenized_file.write ""
          file.read.should == ""
        end
      end

      context "when writing something" do
        it "writes content to the file between tokens" do
          tokenized_file.write "a"
          file.read.should == "#{start_token}\na\n#{end_token}\n"
        end
      end
    end
  end
end
