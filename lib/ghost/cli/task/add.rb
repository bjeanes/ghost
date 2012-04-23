Ghost::Cli.task :add do
  desc "Add a host"
  def perform(host, ip = nil)
    host = Ghost::Host.new(*[host, ip].compact)
    Ghost.store.add(host)
    puts "[Adding] #{host.name} -> #{host.ip}"
  rescue Ghost::Host::NotResolvable
    abort "Unable to resolve IP address for target host #{ip.inspect}."
  end
end
