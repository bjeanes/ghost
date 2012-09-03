Ghost::Cli.task :export do
  desc "Export all hosts in /etc/hosts format"
  def perform
    Ghost.store.all.each do |host|
      puts "#{host.ip} #{host.name}"
    end
  end

  help do
    <<-EOF.unindent
    Usage: ghost export

    #{desc}.

    The export will be printed to standard out.
    EOF
  end
end

