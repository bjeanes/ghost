Ghost::Cli.task :help, nil do
  def perform(task=nil)
    tasks = Ghost::Cli.tasks.values.uniq

    puts "USAGE: ghost <task> [<args>]"
    puts ""
    puts "The ghost tasks are:"

    size = tasks.map { |t| t.name.length }.max
    tasks.sort_by(&:name).each do |task|
      next unless task.desc
      puts "  #{task.name.to_s.ljust(size + 1)}    #{task.desc}"
    end

    puts ""
    puts "See 'ghost help <task>' for more information on a specific task."
  end
end
