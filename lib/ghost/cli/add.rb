Ghost::Cli.task :add do
  def perform(*)
    Ghost.store.add(host)
    puts "  [Adding] #{host.name} -> #{host.ip}"
  end
end
