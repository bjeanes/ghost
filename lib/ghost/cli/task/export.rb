Ghost::Cli.task :export do
  desc "Export all hosts in /etc/hosts format"
  def perform
    Ghost.store.all.each do |host|
      puts "#{host.ip} #{host.name}"
    end
  end
end

