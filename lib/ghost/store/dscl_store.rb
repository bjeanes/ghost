require 'ghost/host'

module Ghost
  module Store
    # TODO: How to write these tests without actually
    #       destroying local hosts or needing sudo?
    #
    #       How to run off OS X?
    #
    #       Setting expectations for the calling the
    #       dscl commands is basically just testing
    #       the implementation instead of the side
    #       effect. Useless tests?
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
      end

      def empty
      end
    end
  end
end
