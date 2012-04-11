# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ghost"
  s.version = "0.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bodaniel Jeanes"]
  s.autorequire = "ghost"
  s.date = "2012-04-10"
  s.description = "Allows you to create, list, and modify local hostnames"
  s.email = "me@bjeanes.com"
  s.executables = ["ghost", "ghost-ssh"]
  s.files = ["LICENSE", "README", "bin/ghost", "bin/ghost-ssh", "lib/ghost", "lib/ghost/linux-host.rb", "lib/ghost/mac-host.rb", "lib/ghost/ssh_config.rb", "lib/ghost/version.rb", "lib/ghost.rb", "spec/etc_hosts_spec.rb", "spec/ghost_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/ssh_config_spec.rb", "spec/ssh_config_template"]
  s.homepage = "http://github.com/bjeanes/ghost"
  s.require_paths = ["lib"]
  s.rubyforge_project = "ghost"
  s.rubygems_version = "1.8.10"
  s.summary = "Allows you to create, list, and modify local hostnames"
  s.test_files = ["spec/etc_hosts_spec.rb", "spec/ghost_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/ssh_config_spec.rb", "spec/ssh_config_template"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
