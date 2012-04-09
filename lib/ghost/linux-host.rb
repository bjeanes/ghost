require 'socket'

module Ghost
  class Host
    attr_reader :host, :ip

    def initialize(host, ip)
      @host = host
      @ip = ip
    end

    def ==(other)
      @host == other.host && @ip = other.ip
    end

    alias :to_s :host
    alias :name :host
    alias :hostname :host

    @@hosts_file = '/etc/hosts'
    @@start_token, @@end_token = '# ghost start', '# ghost end'

    class << self
      protected :new

      def list
        with_exclusive_file_access(true) do |file|
          entries = []
          in_ghost_area = false
          file.pos = 0

          file.each do |line|
            if !in_ghost_area and line =~ /^#{@@start_token}/
              in_ghost_area = true
            elsif in_ghost_area
              if line =~ /^#{@@end_token}/o
                in_ghost_area = false
              elsif line =~ /^(\d+\.\d+\.\d+\.\d+)\s+(.*)$/
                ip = $1
                hosts = $2.split(/\s+/)
                hosts.each { |host| entries << Host.new(host, ip) }
              end
            end
          end

          entries
        end
      end

      def add(host, ip = "127.0.0.1", force = false)
        with_exclusive_file_access do
          if find_by_host(host).nil? || force
            hosts = list
            hosts = hosts.delete_if { |h| h.name == host }

            unless ip[/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/]
              ip = Socket.gethostbyname(ip)[3].bytes.to_a.join('.')
            end

            new_host = Host.new(host, ip)

            hosts << new_host
            write_out!(hosts)

            new_host
          else
            raise "Can not overwrite existing record"
          end
        end
      end

      def find_by_host(hostname)
        list.find { |host| host.hostname == hostname }
      end

      def find_by_ip(ip)
        list.find_all{ |host| host.ip == ip }
      end

      def empty!
        write_out!([])
      end

      def delete(name)
        with_exclusive_file_access do
          hosts = list
          hosts = hosts.delete_if { |host| host.name == name }
          write_out!(hosts)
        end
      end

      def delete_matching(pattern)
        with_exclusive_file_access do
          pattern = Regexp.escape(pattern)
          hosts = list.select { |host| host.name.match(/#{pattern}/) }
          hosts.each { |host| delete(host.name) }
          hosts
        end
      end

      protected

      def with_exclusive_file_access(read_only = false)
        return_val = nil
        flag = read_only ? 'r' : 'r+'

        if @_file
          return_val = yield @_file
        else
          File.open(@@hosts_file, flag) do |f|
            f.flock File::LOCK_EX
            begin
              @_file = f
              return_val = yield f
            ensure
              @_file = nil
            end
          end
        end

        return_val
      end

      def write_out!(hosts)
        with_exclusive_file_access do |f|
          new_ghosts = hosts.inject("") {|s, h| s + "#{h.ip} #{h.hostname}\n" }

          output = ""
          in_ghost_area, seen_tokens = false,false
          f.pos = 0

          f.each do |line|
            if line =~ /^#{@@start_token}/o
              in_ghost_area, seen_tokens = true,true
              output << line << new_ghosts
            elsif line =~ /^#{@@end_token}/o
              in_ghost_area = false
            end
            output << line unless in_ghost_area
          end
          if !seen_tokens
            output << surround_with_tokens( new_ghosts )
          end

          f.pos = 0
          f.print output
          f.truncate(f.pos)
        end
      end


      def surround_with_tokens(str)
        "\n#{@@start_token}\n#{str}#{@@end_token}\n"
      end
    end
  end
end
