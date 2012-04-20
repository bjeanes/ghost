$: << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

desc "Generate gemspec"
task :gemspec do
  require 'rubygems/specification'
  require 'ghost/version'
  require 'date'

  spec = Gem::Specification.new do |s|
    s.specification_version = 3 if s.respond_to? :specification_version=
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

    s.author            = "Bodaniel Jeanes"
    s.email             = "me@bjeanes.com"

    s.name              = 'ghost'
    s.version           = Ghost::VERSION
    s.summary           = "Allows you to create, list, and modify local hostnames"
    s.description       = s.summary
    s.homepage          = "http://github.com/bjeanes/ghost"
    s.rubyforge_project = 'ghost'

    s.date              = Date.today.strftime

    s.files             = %w(LICENSE README.md) + Dir.glob("{bin,lib,spec}/**/*")
    s.require_paths     = %w[lib]
    s.test_files        = s.files.select { |path| path =~ /^spec\// }
    s.executables       += %w[ghost]
    s.autorequire       = "ghost"
    s.has_rdoc          = false

    s.add_development_dependency "rspec", "2.9.0"
  end

  File.open("ghost.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

task :default => [:spec, :gem]

task :spec do
  puts "Running specs\n\n"
  unless system("bundle exec rspec spec")
    abort "Specs failed!"
  end
end

task :gem => :gemspec do
  puts "Building gem to pkg/\n\n"

  if system("gem build ghost.gemspec")
    FileUtils.mkdir_p("pkg")
    FileUtils.mv("ghost-#{Ghost::VERSION}.gem", "pkg")
  else
    abort "Building gem failed!"
  end
end
