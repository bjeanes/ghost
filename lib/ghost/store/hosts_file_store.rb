require 'set'

require 'ghost/host'

module Ghost
  module Store
    class HostsFileStore
      START_TOKEN = "# ghost start"
      END_TOKEN   = "# ghost end"

      attr_accessor :path

      def initialize(path = "/etc/hosts")
        self.path = path
      end

      def add(host)
        sync do |buffer|
          buffer[host.ip] << host.name
          buffer_changed!
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
        result = false
        sync do |buffer|
          buffer.each do |ip, names|
            if names.include?(host.name)
              result = true
              names.delete(host.name)
              buffer_changed!
            end
          end
        end
        result
      end

      def empty
        result = false
        sync do |buffer|
          unless buffer.empty?
            result = true
            buffer.replace({})
            buffer_changed!
          end
        end
        result
      end

      private # TODO: Add buffer management code to new class

      def buffer_changed?
        @buffer_changed
      end

      def buffer_changed!
        @buffer_changed = true
      end

      def with_buffer
        @buffer_changed = false
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

        with_file do |file|
          with_buffer do |buffer|
            original_lines = read_file(file, buffer)

            result = yield(buffer)

            if buffer_changed?
              file.reopen(file.path, 'w')
              file.truncate(0)
              file.puts(original_lines)
              file.puts(content(buffer))
            end
          end
        end

        result
      end

      def with_file
        # FIXME: Add exclusive lock on file?
        File.open(path, 'r') do |file|
          yield file
        end
      end

      def read_file(file, buffer)
        between_tokens = false
        original_lines = []

        file.each_line do |line|
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

        original_lines
      end

      def content(buffer)
        ips   = buffer.keys.sort
        lines = ips.map do |ip|
          unless (hosts = buffer[ip]).empty?
            "#{ip} #{buffer[ip].to_a.join(" ")}"
          end
        end

        <<-EOS.gsub(/^\s+/, '')
          #{START_TOKEN}
          #{lines.compact.join($/)}
          #{END_TOKEN}
        EOS
      end
    end
  end
end
