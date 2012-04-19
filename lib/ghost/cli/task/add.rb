Ghost::Cli.task :add do
  def perform(*args)
    host = Ghost::Host.new(*args.take(2))
    Ghost.store.add(host)
    puts "[Adding] #{host.name} -> #{host.ip}"
  end
end
