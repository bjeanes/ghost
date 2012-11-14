Ghost::Cli.task :set do
  desc "Add a host or modify the IP of an existing host"
  def perform(host, ip = nil)
    host = Ghost::Host.new(*[host, ip].compact)
    Ghost.store.set(host)
    puts "[Setting] #{host.name} -> #{host.ip}"
  rescue Ghost::Host::NotResolvable
    abort "Unable to resolve IP address for target host #{ip.inspect}."
  end

  help do
    <<-EOF.unindent
    Usage: ghost set <local host name> [<remote host name>|<IP address>]

    #{desc}.

    If a second parameter is not provided, it defaults to 127.0.0.1

    Examples:
      ghost set my-localhost          # points to 127.0.0.1
      ghost set google.dev google.com # points to the IP of google.com
      ghost set router 192.168.1.1    # points to 192.168.1.1
    EOF
  end
end
