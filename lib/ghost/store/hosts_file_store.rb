module Ghost
  module Store
    class HostsFileStore
      attr_accessor :io

      def initialize(io)
        self.io = io
      end

      def add(host)
        io.seek(io.size)
        io.puts "# ghost start"
        io.puts "#{host.ip} #{host.name}"
        io.puts "# ghost end"
        io.flush
        io.rewind

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
    end
  end
end
