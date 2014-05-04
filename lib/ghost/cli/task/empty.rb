Ghost::Cli.task :bust, :empty do
  desc "Clear all ghost-managed hosts"

  def perform
    print "[Emptying] "
    Ghost.store.empty
    puts "Done."
  end

  help do
    <<-EOF.unindent
    Usage: ghost empty

    The empty task will delete all ghost-managed hosts from
    the host store.
    EOF
  end
end
