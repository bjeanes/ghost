Ghost::Cli.task :add do
  def perform(host, ip = nil)
    host = Ghost::Host.new(*[host, ip].compact)
    Ghost.store.add(host)
    puts "[Adding] #{host.name} -> #{host.ip}"
  end
end
