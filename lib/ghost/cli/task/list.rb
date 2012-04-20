Ghost::Cli.task :list do
  def perform(filter = nil)

    hosts = if filter
      filter = $1 if filter =~ %r|^/(.*)/$|
      Ghost.store.find(/#{filter}/i)
    else
      Ghost.store.all
    end

    pad = hosts.map {|h| h.name.length }.max

    puts "Listing #{hosts.size} host(s):"
    hosts.each do |host|
      puts "#{host.name.rjust(pad + 2)} -> #{host.ip}"
    end
  end
end
