Ghost::Cli.task :import do
  desc "Import hosts in /etc/hosts format"
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

  help do
    <<-EOF.unindent
    Usage: ghost import file1 [file2 [file3 ...]]

    #{desc}.

    Each file provided will be read in as an import file. The
    behavior for duplicate or conflicting entries is not currently
    defined.
    EOF
  end
end
