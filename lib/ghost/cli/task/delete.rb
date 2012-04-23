Ghost::Cli.task :delete, :rm, :del, :remove do
  desc "Remove a ghost-managed host"
  def perform(host)
    host = /#{$1}/i if %r[^/(.+)/$] =~ host
    Ghost.store.delete(host)
  end
end
