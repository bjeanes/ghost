require 'set'

require 'ghost/host'
require 'ghost/tokenized_file'
require 'resolv'

module Ghost
  module Store
    # TODO: A lot of this duplicates Resolv::Hosts in Ruby stdlib.
    #       Can that be modifiied to use tokens in place of this?
    class HostsFileStore
      MAX_HOSTS_PER_LINE = 5
      DEFAULT_FILE = Resolv::Hosts::DefaultFileName

      attr_accessor :path, :file
      attr_reader :section_name

      def initialize(options = {})
        self.path         = options.fetch(:path, DEFAULT_FILE)
        self.section_name = options.fetch(:section_name)

        self.file = Ghost::TokenizedFile.new(self.path,
          "# #{self.section_name} start",
          "# #{self.section_name} end")
      end

      def section_name=(name)
        if self.section_name
          raise RuntimeError, "Cannot change section name"
        end
        @section_name = name
      end

      def add(host)
        sync do |buffer|
          buffer[host.ip] << host.name
          buffer_changed!
        end

        true
      end

      def set(host)
        sync do |buffer|
          delete_host host, buffer
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
        sync do |buffer|
          delete_host host, buffer, :strict
        end
      end

      def purge(host)
        sync do |buffer|
          delete_host host, buffer
        end
      end

      def delete_host(host, buffer, strict = false)
        result = SortedSet.new
        buffer.each do |ip, names|
          names.each do |name|
            if host.kind_of? Host
              next unless host.name == name
            elsif host.kind_of? String
              next unless host == name
            else
              next unless host.match(name)
            end

            next if host.respond_to?(:ip) && host.ip != ip && strict

            result << Ghost::Host.new(name, ip)
            names.delete(name)
            buffer_changed!
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

      def parse_into_buffer(content, buffer)
        content.split($/).each do |line|
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
        lines = ips.flat_map do |ip|
          buffer \
            .fetch(ip, []) \
            .each_slice(MAX_HOSTS_PER_LINE) \
            .map { |hosts| [ip, *hosts].join(' ') }
        end

        lines.compact.join($/)
      end
    end
  end
end
