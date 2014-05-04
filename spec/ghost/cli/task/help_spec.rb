require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  describe "help" do
    let(:overview) do
      <<-EOF.unindent
        USAGE: ghost <task> [<args>]

        The ghost tasks are:
          add        Add a host
          bust       Clear all ghost-managed hosts
          delete     Remove a ghost-managed host
          export     Export all hosts in /etc/hosts format
          import     Import hosts in /etc/hosts format
          list       Show all (or a filtered) list of hosts
          set        Add a host or modify the IP of an existing host

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
  end
end
