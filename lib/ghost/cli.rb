require File.expand_path("#{File.dirname(__FILE__)}/../ghost")

require 'optparse'

module Ghost
  class Cli
    attr_accessor :out

    def initialize(out = STDOUT)
      self.out = out
    end

    def parse(args)
      opts = OptionParser.new do |o|
        o.on("-v", "--version") do
          out.puts "ghost #{Ghost::VERSION}"
          exit
        end
      end

      opts.parse!(args)
    end
  end
end
