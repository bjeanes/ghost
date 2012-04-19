Ghost::Cli.task :list do
  def perform(*)
    hosts = Ghost.store.all

    pad = hosts.map {|h| h.name.length }.max

    puts "Listing #{hosts.size} host(s):"
    hosts.each do |host|
      puts "#{host.name.rjust(pad + 2)} -> #{host.ip}"
    end
  end
end
