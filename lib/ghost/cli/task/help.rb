Ghost::Cli.task :help, nil do
  def perform(task=nil)
    puts "USAGE: ghost <task> [<args>]"
    puts ""
    puts "The ghost tasks are:"

    tasks_to_show do |name, desc|
      puts "  #{name}     #{desc}"
    end

    puts ""
    puts "See 'ghost help <task>' for more information on a specific task."
  end

  private

  def tasks_to_show
    tasks = Ghost::Cli.tasks.values.uniq
    size = tasks.map { |t| t.name.length }.max
    tasks.sort_by(&:name).each do |task|
      next unless task.desc
      yield task.name.ljust(size), task.desc
    end
  end
end
