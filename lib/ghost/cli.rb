require File.expand_path("#{File.dirname(__FILE__)}/../ghost")

require 'optparse/subcommand'
require 'optparse/version'

module Ghost
  class Cli
    attr_accessor :out, :parser, :args

    def initialize(args, out = STDOUT)
      self.args = args
      self.out  = out

      setup_parser
    end

    def parse
      parser.send :parse!, args
    end

    private

    def setup_parser
      self.parser = OptionParser.new do |o|
        o.on_head '-v', '--version' do
          puts parser.ver
        end

        o.subcommand 'add' do
          add
          exit
        end

        o.subcommand 'list' do
          list
          exit
        end

        o.subcommand 'export' do
          export
          exit
        end

        o.subcommand 'empty' do
          empty
          exit
        end
      end

      parser.program_name = "ghost"
      parser.version = Ghost::VERSION
    end

    def add
      host = Ghost::Host.new(*args.take(2))
      Ghost::Host.add(host)

      puts "  [Adding] #{host.name} -> #{host.ip}"
    end

    def list
      hosts = Ghost::Host.list

      pad = hosts.map {|h| h.name.length }.max

      puts "Listing #{hosts.size} host(s):"
      hosts.each do |host|
        puts "#{host.name.rjust(pad + 2)} -> #{host.ip}"
      end
    end

    def export
      Ghost::Host.list.each do |host|
        puts "#{host.ip} #{host.name}"
      end
    end

    def empty
      print "  [Emptying] "
      Ghost::Host.empty!
      puts "Done."
    end

    def print(*args)
      out.print(*args)
    end

    def puts(*args)
      out.puts(*args)
    end
  end
end
