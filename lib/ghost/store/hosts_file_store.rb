require 'set'
require 'stringio'

require 'ghost/host'

module Ghost
  module Store
    class HostsFileStore
      START_TOKEN   = "# ghost start"
      END_TOKEN     = "# ghost end"

      attr_accessor :io

      def initialize(io)
        self.io = io
      end

      def add(host)
        sync do |buffer|
          buffer[host.ip] << host.name
        end

        true
      end

      def all
        result = []
        sync do |buffer|
          buffer.each do |ip, hosts|
            hosts.each do |host|
              result << Ghost::Host.new(host, ip)
            end
          end
        end
        result.sort
      end

      def delete(host)
        false
      end

      def empty
        false
      end

      private # TODO: Add buffer management code to new class

      def buffer_changed?
        !!@buffer_changed
      end

      def buffer_changed!
        @buffer_changed = true
      end

      def with_buffer
        yield(Hash.new { |hash, key| hash[key] = SortedSet.new })
      end

      def parse_into_buffer(line, buffer)
        ip, hosts = *line.scan(/^\s*([^\s]+)\s+([^#]*)/).first

        return unless ip and hosts

        hosts.split(/\s+/).each do |host|
          buffer[ip] << host
        end
      end

      def sync
        result = nil
        with_buffer do |buffer|
          original_lines = read_file(buffer)

          result = yield(buffer)

          io.puts(original_lines)
          io.puts(content(buffer))
          io.rewind
        end

        result
      end

      def read_file(buffer)
        between_tokens = false
        original_lines = []

        io.rewind
        io.each do |line|
          if line =~ /^\s*#{START_TOKEN}\s*$/
            between_tokens = true
          elsif line =~ /^\s*#{END_TOKEN}\s*$/
            between_tokens = false
          elsif between_tokens
            parse_into_buffer(line, buffer)
          else
            original_lines << line
          end
        end

        io.rewind
        io.truncate(0)

        original_lines
      end

      def content(buffer)
        ips   = buffer.keys.sort
        lines = ips.map { |ip| "#{ip} #{buffer[ip].to_a.join(" ")}" }

        <<-EOS.gsub(/^\s+/, '')
          #{START_TOKEN}
          #{lines.join($/)}
          #{END_TOKEN}
        EOS
      end
    end
  end
end
