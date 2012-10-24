require 'set'

require 'ghost/host'
require 'ghost/tokenized_file'
require 'resolv'

module Ghost
  module Store
    # TODO: A lot of this duplicates Resolv::Hosts in Ruby stdlib.
    #       Can that be modifiied to use tokens in place of this?
    class HostsFileStore
      attr_accessor :path, :file

      def initialize(path = Resolv::Hosts::DefaultFileName)
        self.path = path
        self.file = Ghost::TokenizedFile.new(path, "# ghost start", "# ghost end")
      end

      def add(host)
        sync do |buffer|
          buffer[host.ip] << host.name
          buffer_changed!
        end

        true
      end

      def all
        sync do |buffer|
          buffer.map do |ip, hosts|
            hosts.map { |h| Ghost::Host.new(h, ip) }
          end.flatten.sort
        end
      end

      def find(filter)
        all.select { |host| host.name =~ filter }
      end

      def delete(host)
        result = SortedSet.new
        sync do |buffer|
          buffer.each do |ip, names|
            names.dup.each do |name|
              next unless host.match(name)
              next if host.respond_to?(:ip) && host.ip != ip

              result << Ghost::Host.new(name, ip)
              names.delete(name)
              buffer_changed!
            end
          end
        end
        result.to_a
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

      def parse_into_buffer(lines, buffer)
        lines.split($/).each do |line|
          ip, hosts = *line.scan(/^\s*([^\s]+)\s+([^#]*)/).first

          return unless ip and hosts

          hosts.split(/\s+/).each do |host|
            buffer[ip] << host
          end
        end
      end

      def sync
        result = nil

        with_buffer do |buffer|
          parse_into_buffer(file.read, buffer)
          result = yield(buffer)
          file.write(content(buffer)) if buffer_changed?
        end

        result
      end

      def content(buffer)
        ips   = buffer.keys.sort
        lines = ips.map do |ip|
          unless (hosts = buffer[ip]).empty?
            "#{ip} #{buffer[ip].to_a.join(" ")}"
          end
        end

        lines.compact.join($/)
      end
    end
  end
end
