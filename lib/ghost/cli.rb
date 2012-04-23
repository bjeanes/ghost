require 'ghost'

require 'optparse'
require 'optparse/version'

module Ghost
  class Cli
    attr_accessor :out, :parser

    def initialize(out = STDOUT)
      self.out  = out

      setup_parser
    end

    def parse(args = ARGV)
      parser.parse! args

      arg = args.shift.to_s

      if (task = tasks[arg])
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
          exit
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
