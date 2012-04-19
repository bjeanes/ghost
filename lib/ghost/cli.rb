require File.expand_path("#{File.dirname(__FILE__)}/../ghost")

require 'optparse'
require 'optparse/version'

module Ghost
  class Cli
    attr_accessor :out, :parser, :args

    def initialize(args, out = STDOUT)
      self.args = args.dup
      self.out  = out

      setup_parser
    end

    def parse
      parser.parse! args

      arg = args.shift
      return unless arg

      if (task = tasks[arg.to_sym])
        task.perform(*args)
      else
        raise "No such task"
      end
    end

    private

    def setup_parser
      self.parser = OptionParser.new do |o|
        o.on_tail '-v', '--version' do
          puts parser.ver
        end
      end

      parser.program_name = "ghost"
      parser.version = Ghost::VERSION
    end

    def print(*args)
      out.print(*args)
    end

    def puts(*args)
      out.puts(*args)
    end
  end
end

require 'ghost/cli/task'
