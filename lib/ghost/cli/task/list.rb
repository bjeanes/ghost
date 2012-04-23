Ghost::Cli.task :list do
  desc "Show all (or a filtered) list of hosts"
  def perform(filter = nil)
    hosts = get_hosts(filter)

    puts "Listing #{hosts.size} host(s):"

    pad = hosts.map {|h| h.name.length }.max
    hosts.each do |host|
      puts "#{host.name.rjust(pad + 2)} -> #{host.ip}"
    end
  end

  private

  def get_hosts(filter)
    hosts = if filter
      filter = $1 if filter =~ %r|^/(.*)/$|
      Ghost.store.find(/#{filter}/i)
    else
      Ghost.store.all
    end
  end
end
