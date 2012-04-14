require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")
require 'ghost/cli'

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

  describe "--version" do
    it "outputs the gem name and version" do
      ghost("--version").should == "ghost #{Ghost::VERSION}"
      ghost("-v").should == "ghost #{Ghost::VERSION}"
    end
  end
end
