Ghost::Cli.task :help, nil do
  def perform(task=nil)
    puts """USAGE: ghost <task> [<args>]

    The ghost tasks are:
      add        Add a host
      delete     Remove a ghost-managed host
      list       Show all (or a filtered) list of hosts
      import     Import hosts in /etc/hosts format
      export     Export all hosts in /etc/hosts format
      empty      Clear all ghost-managed hosts

    See 'ghost help <task>' for more information on a specific task.
    """.gsub(/^ {4}/,'').strip
  end
end
