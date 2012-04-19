Ghost::Cli.task :import do
  def perform(*files)
    files.each do |file|
      File.readlines(file).each do |line|
        ip, name = *line.split(/\s+/)
        host = Ghost::Host.new(name, ip)
        Ghost.store.add(host)
        puts "[Adding] #{host.name} -> #{host.ip}"
      end
    end
  end
end
