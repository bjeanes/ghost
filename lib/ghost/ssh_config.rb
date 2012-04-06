class SshConfigDuplicateError < StandardError; end

class SshConfig
  @@ssh_config = "#{ENV['HOME']}/.ssh/config"

  attr_accessor :host, :hostname, :user, :port
  alias :to_s :host

  def initialize(host, hostname, user, port)
    @host = host
    @hostname = hostname
    @user = user
    @port = port
  end

  class << self
    protected :new

    def list
      lines = File.read(@@ssh_config).split("\n")

      entries = []
      current_entry = []

      lines << ""
      lines.each do |line|
        if line.strip.empty?
          entries << parse(current_entry) if current_entry.any?
          current_entry = []
        else
          current_entry << line
        end
      end

      entries
    end

    def add(args)
      host = args[:host]
      hostname = args[:hostname]
      user = args[:user] || "root"
      port = args[:port] || "22"

      force = args[:force]

      if find_by_host(host).nil? || force
        delete(host)

        new_config = SshConfig.new(host, hostname, user, port)

        configs = list
        configs << new_config

        write(configs)

        new_config
      else
        raise SshConfigDuplicateError, "Can not overwrite existing record"
      end
    end

    def find_by_host(host)
      list.find { |c| c.host == host }
    end

    def empty!
      write([])
    end

    def delete(host)
      configs = list
      configs = configs.delete_if { |c| c.host == host }
      write(configs)
    end

    def write(configs)
      hosts = []

      configs.sort! { |a,b| a.host <=> b.host }
      configs.each do |c|
        hosts << "Host #{c.host}"
        hosts << "  HostName #{c.hostname}"
        hosts << "  User #{c.user}" if c.user
        hosts << "  Port #{c.port}" if c.port
        hosts << ""
      end

      File.open(@@ssh_config, 'w') {|f| f.print hosts.join("\n") }
    end

    def parse(config)
      host = config.first[/Host (.*)/, 1]
      config_hash = {}

      config[1..-1].each do |entry|
        entry.strip!
        next if entry.empty?
        key, value = entry.strip.split(" ")
        config_hash[key.downcase] = value
      end

      SshConfig.new(host,
        config_hash['hostname'], config_hash['user'],
        config_hash['port'])
    end

  end
end
