begin
  begin
    require 'spec'
  rescue LoadError
    require 'rubygems'
    require 'spec'
  end
  require 'spec/rake/spectask'

  desc "Run the specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
rescue LoadError
  task :spec do
    puts <<-EOS
  To use rspec for testing you must install rspec gem:
      gem install rspec
  EOS
  end
end

