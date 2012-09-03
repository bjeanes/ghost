Ghost::Cli.task :help, nil do
  def perform(name=nil)
    return overview unless name

    task = tasks_by_name[name]
    abort "No help for task '#{name}'" unless task && task.help

    puts task.help
  end

  private

  def overview
    puts "USAGE: ghost <task> [<args>]"
    puts ""
    puts "The ghost tasks are:"

    tasks_to_show do |name, desc|
      puts "  #{name}     #{desc}"
    end

    puts ""
    puts "See 'ghost help <task>' for more information on a specific task."
  end

  def tasks_by_name
    Ghost::Cli.tasks
  end

  def tasks
    tasks_by_name.values.uniq
  end

  def tasks_to_show
    size = tasks.map { |t| t.name.length }.max
    tasks.sort_by(&:name).each do |task|
      next unless task.desc
      yield task.name.ljust(size), task.desc
    end
  end
end
