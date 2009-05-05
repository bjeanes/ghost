# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ghost}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bodaniel Jeanes"]
  s.autorequire = %q{ghost}
  s.date = %q{2009-03-07}
  s.default_executable = %q{ghost}
  s.description = %q{Allows you to create, list, and modify .local hostnames in 10.5 with ease}
  s.email = %q{me@bjeanes.com}
  s.executables = ["ghost"]
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "bin/ghost", "lib/ghost", "lib/ghost/linux-host.rb", "lib/ghost/mac-host.rb", "lib/ghost.rb", "spec/ghost_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bjeanes/ghost}
  s.rdoc_options = ["--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ghost}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Allows you to create, list, and modify .local hostnames in 10.5 with ease}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
