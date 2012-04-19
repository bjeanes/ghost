Ghost::Cli.task :empty do
  def perform(*)
    print "[Emptying] "
    Ghost.store.empty
    puts "Done."
  end
end
