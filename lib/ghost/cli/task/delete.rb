Ghost::Cli.task :delete, :rm, :del, :remove do
  desc "Remove a ghost-managed host"
  def perform(host)
    host = /#{$1}/i if %r[^/(.+)/$] =~ host
    Ghost.store.delete(host)
  end

  help do
    <<-EOF.unindent
    Usage: ghost delete <host name|regex>

    #{desc}.

    The delete task accepts either a literal host name, or a regular
    expression, notated with surrounding forward slashes (/). If a
    host name is provided, it will delete only the entries whose host
    names are equal to the provided host name. If a regular expression
    is provided, all entries whose host names match the regular
    expression will be deleted.

    Depending on your shell, you may need to escape or quote the
    regular expression to ensure that the shell doesn't perform
    expansion on the expression.

    Examples:
      ghost delete foo.com       # will delete foo.com
      ghost delete /^fo+\\.com$/  # will delete fo.com, fooooo.com, etc.
    EOF
  end
end
