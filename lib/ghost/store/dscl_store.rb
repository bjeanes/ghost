require 'ghost/host'
require 'set'

module Ghost
  module Store
    class DsclStore
      class Dscl
        class << self
          def list(domain)
            `dscl % -readall /Local/Default/Hosts 2>&1` % domain
          end

          # TODO is shell injection a concern here?
          def read(domain, host)
            `dscl % -read /Local/Default/Hosts/%s 2>&1` % [domain, host]
          end

          def create(domain, host, ip)
            `dscl % -create /Local/Default/Hosts/%s IPAddress %s 2>&1` % [domain, host, ip]
          end

          def delete(domain, host)
            `dscl % -delete /Local/Default/Hosts/%s 2>&1` % [domain, host]
          end
        end
      end

      attr_accessor :domain

      def initialize(domain = "localhost")
        self.domain = domain
      end

      def add(host)
        Dscl.create(domain, host.name, host.ip)
        true
      end

      def all
        Dscl.list(domain).map do |host|
          name = host.scan(/^RecordName: (.+)$/).flatten.first
          ip   = host.scan(/^IPAddress: (.+)$/).flatten.first

          Ghost::Host.new(name, ip)
        end
      end

      def find(regex)
        all.select { |h| h.name =~ regex }
      end

      def delete(host)
        result = SortedSet.new

        all.each do |existing_host|
          next unless host.match(existing_host.name)
          next if host.respond_to?(:ip) && host.ip != existing_host.ip

          Dscl.delete(domain, existing_host.name)
          result << existing_host
        end

        result.to_a
      end

      def empty
      end
    end
  end
end
