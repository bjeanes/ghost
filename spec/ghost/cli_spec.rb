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

  describe "modify"
  describe "delete"
  describe "delete_matching"
  describe "list" do
    before do
      Ghost::Host.stub(:list => [
        Ghost::Host.new("gist.github.com", "10.0.0.1"),
        Ghost::Host.new("google.com", "192.168.1.10")
      ])
    end

    it "outputs of all hostnames" do
      ghost("list").should == %"
        Listing 2 host(s):
          gist.github.com -> 10.0.0.1
               google.com -> 192.168.1.10
      ".gsub(/^\s{8}/,'').strip.chomp
    end
  end
  describe "empty"
  describe "export"
  describe "import"
end
