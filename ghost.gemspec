# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ghost"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bodaniel Jeanes"]
  s.autorequire = "ghost"
  s.date = "2012-04-18"
  s.description = "Allows you to create, list, and modify local hostnames"
  s.email = "me@bjeanes.com"
  s.executables = ["ghost", "ghost-ssh"]
  s.extra_rdoc_files = ["README.md", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README.md", "Rakefile", "TODO", "bin/ghost", "bin/ghost-ssh", "lib/ghost", "lib/ghost/linux-host.rb", "lib/ghost/mac-host.rb", "lib/ghost/ssh_config.rb", "lib/ghost.rb", "spec/etc_hosts_spec.rb", "spec/ghost_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/ssh_config_spec.rb", "spec/ssh_config_template"]
  s.homepage = "http://github.com/bjeanes/ghost"
  s.rdoc_options = ["--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "ghost"
  s.rubygems_version = "1.8.10"
  s.summary = "Allows you to create, list, and modify local hostnames"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
