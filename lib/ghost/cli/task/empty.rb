Ghost::Cli.task :empty do
  desc "Clear all ghost-managed hosts"

  def perform
    print "[Emptying] "
    Ghost.store.empty
    puts "Done."
  end
end
