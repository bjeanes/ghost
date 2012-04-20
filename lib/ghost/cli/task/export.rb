Ghost::Cli.task :export do
  def perform
    Ghost.store.all.each do |host|
      puts "#{host.ip} #{host.name}"
    end
  end
end

