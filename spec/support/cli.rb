require 'fileutils'
require 'tempfile'
require 'tmpdir'

module CliSpecs
  def self.included(klass)
    klass.before do
      FileUtils.touch(store_path)
      Ghost.store = store
    end

    klass.let(:store_path) { File.join(Dir.tmpdir, "etc_hosts.#{Process.pid}.#{rand(9999)}") }
    klass.let(:store)      { Ghost::Store::HostsFileStore.new(section_name: 'ghost', path: store_path) }
  end

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

RSpec.configure do |c|
  c.include CliSpecs, :type => :cli
end
