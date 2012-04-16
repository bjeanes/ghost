module Ghost
  module Store
    class HostsFileStore
      attr_accessor :io

      def initialize(io)
        self.io = io

      end

      def add(host)
        manage do
          puts "# ghost start"
          puts "#{host.ip} #{host.name}"
          puts "# ghost end"
        end

        true
      end

      def all
        []
      end

      def delete(host)
        false
      end

      def empty
        false
      end

      private

      def manage(&block)
        io.seek(io.size)
        io.instance_eval(&block)
        io.flush
        io.rewind
      end
    end
  end
end
