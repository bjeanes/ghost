require 'fileutils'
require 'tempfile'
require 'tmpdir'
require 'ghost/cli'

class CliSpec < MiniTest::Spec
  register_spec_type(Ghost::Cli, self)

  before do
    FileUtils.touch(store_path)
    Ghost.store = store
  end

  let(:store_path) { File.join(Dir.tmpdir, "etc_hosts.#{Process.pid}.#{rand(9999)}") }
  let(:store)      { Ghost::Store::HostsFileStore.new(store_path) }

  def ghost(args)
    out = StringIO.new
    Ghost::Cli.new(out).parse(args.split(/\s+/))
    out.rewind
    out.read
  rescue SystemExit
    out.rewind
    out.read
  end
end
