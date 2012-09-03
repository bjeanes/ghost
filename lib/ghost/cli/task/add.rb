Ghost::Cli.task :add do
  desc "Add a host"
  def perform(host, ip = nil)
    host = Ghost::Host.new(*[host, ip].compact)
    Ghost.store.add(host)
    puts "[Adding] #{host.name} -> #{host.ip}"
  rescue Ghost::Host::NotResolvable
    abort "Unable to resolve IP address for target host #{ip.inspect}."
  end

  help do
    <<-EOF.unindent
    Usage: ghost add <local host name> [<remote host name>|<IP address>]

    #{desc}.

    If a second parameter is not provided, it defaults to 127.0.0.1

    Examples:
      ghost add my-localhost          # points to 127.0.0.1
      ghost add google.dev google.com # points to the IP of google.com
      ghost add router 192.168.1.1    # points to 192.168.1.1
    EOF
  end
end
