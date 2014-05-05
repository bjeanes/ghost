require 'ghost'
require 'ghost/store'

require 'optparse'
require 'optparse/version'

module Ghost
  class Cli
    attr_accessor :out, :parser, :store

    def initialize(out = STDOUT)
      self.store = Ghost::Store::HostsFileStore.new(section_name: 'ghost')
      self.out   = out

      setup_parser
    end

    def parse(args = ARGV)
      parser.parse! args

      arg = args.shift.to_s

      if (task = tasks[arg])
        task.perform(*args)
      else
        abort "No such task"
      end
    rescue Errno::EACCES
      abort "Insufficient privileges. Try using `sudo` or running as root."
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

    # TODO: should output to STDERR
    def abort(*args)
      puts *args
      exit 1
    end
  end
end

require 'ghost/cli/task'
