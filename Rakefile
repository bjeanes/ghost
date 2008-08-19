require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'

GEM = "ghost"
GEM_VERSION = [0,0,1]
AUTHOR = "Bodaniel Jeanes"
EMAIL = "me@bjeanes.com"
HOMEPAGE = "http://github.com/bjeanes/ghost"
SUMMARY = "Allows you to create, list, and modify .local hostnames in 10.5 with ease"

desc "list tasks"
task :default do
  puts `rake -T`.grep(/^[^(].*$/)
end

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION.join('.')
  s.platform = "universal-darwin-9" # perhaps other *darwin* platforms...
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.rdoc_options << '--title Ghost' << '--main README' << '--line-numbers'
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.requirements << 'Mac OS X Leopard (10.5)'
  s.executables << 'ghost'
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{bin,lib,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end