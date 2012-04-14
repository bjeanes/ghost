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
        o.on_head '-v', '--version' do
          puts parser.ver
        end

        o.subcommand 'list' do
          list
          exit
        end
      end

      parser.program_name = "ghost"
      parser.version = Ghost::VERSION
    end

    def list
      hosts = Ghost::Host.list

      pad = hosts.map {|h| h.name.length }.max

      puts "Listing #{hosts.size} host(s):"
      hosts.each do |host|
        puts "#{host.name.rjust(pad + 2)} -> #{host.ip}"
      end
    end

    def puts(*args)
      out.puts(*args)
    end
  end
end
