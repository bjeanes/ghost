require File.expand_path("#{File.dirname(__FILE__)}/../ghost")

require 'optparse/subcommand'
require 'optparse/version'

module Ghost
  class Cli
    attr_accessor :out, :parser

    def initialize(out = STDOUT)
      self.out = out
      setup_parser
    end

    def parse(args)
      parser.parse(args)
    end

    private

    def setup_parser
      self.parser = OptionParser.new do |o|
        o.on_tail '-v', '--version' do
          out.puts parser.ver
        end
      end

      parser.program_name = "ghost"
      parser.version = Ghost::VERSION
    end
  end
end
