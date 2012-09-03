require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper.rb")
require 'ghost/cli'

describe Ghost::Cli, :type => :cli do
  describe "import" do
    context "with current export format" do
      let(:import) do
        <<-EOI.unindent
        1.2.3.4 foo.com
        2.3.4.5 bar.com
        EOI
      end

      let(:foo_com) { Ghost::Host.new('foo.com', '1.2.3.4') }
      let(:bar_com) { Ghost::Host.new('bar.com', '2.3.4.5') }

      context 'with no file name'
      context 'with STDIN pseudo file name (-)'

      context 'with a file name' do
        it 'adds each entry' do
          file = Tempfile.new('import')
          file.write(import)
          file.close

          ghost("import #{file.path}")

          store.all.should include(foo_com)
          store.all.should include(bar_com)
        end
      end

      context 'with multiple file names'

      context 'when an entry is already present' do
        context 'without the -f flag' do
          it 'skips the existing entries'
          it 'prints a warning about skipped entries'
        end

        context 'with the -f flag' do
          it 'overwrites the existing entries'
        end
      end

      context 'with multiple hosts per line' do
        let(:import) do
          <<-EOI.unindent
          1.2.3.4 foo.com
          2.3.4.5 bar.com subdomain.bar.com
          EOI
        end
      end
    end
  end
end
