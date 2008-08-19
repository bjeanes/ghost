Gem::Specification.new do |s|
  s.name = %q{ghost}
  s.version = "0.0.1"
  s.platform = %q{universal-darwin-9}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bodaniel Jeanes"]
  s.autorequire = %q{ghost}
  s.date = %q{2008-08-19}
  s.default_executable = %q{ghost}
  s.description = %q{Allows you to create, list, and modify .local hostnames in 10.5 with ease}
  s.email = %q{me@bjeanes.com}
  s.executables = ["ghost"]
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "bin/ghost", "lib/ghost", "lib/ghost/host.rb", "lib/ghost.rb", "spec/ghost_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bjeanes/ghost}
  s.rdoc_options = ["--title Ghost", "--main README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.requirements = ["Mac OS X Leopard (10.5)"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Allows you to create, list, and modify .local hostnames in 10.5 with ease}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
