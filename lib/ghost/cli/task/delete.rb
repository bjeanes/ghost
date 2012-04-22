Ghost::Cli.task :delete, :rm, :del, :remove do
  def perform(host)
    host = /#{$1}/i if %r[^/(.+)/$] =~ host
    Ghost.store.delete(host)
  end
end
