# -*- encoding: utf-8 -*-
# stub: ghost 1.0.0.pre.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ghost"
  s.version = "1.0.0.pre.2"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bodaniel Jeanes"]
  s.date = "2014-05-03"
  s.description = "Allows you to create, list, and modify local hostnames on POSIX systems (e.g. Mac OS X and Linux) and Windows"
  s.email = "me@bjeanes.com"
  s.executables = ["ghost"]
  s.files = ["LICENSE", "README.md", "bin/ghost", "lib/ghost", "lib/ghost.rb", "lib/ghost/cli", "lib/ghost/cli.rb", "lib/ghost/cli/task", "lib/ghost/cli/task.rb", "lib/ghost/cli/task/add.rb", "lib/ghost/cli/task/delete.rb", "lib/ghost/cli/task/empty.rb", "lib/ghost/cli/task/export.rb", "lib/ghost/cli/task/help.rb", "lib/ghost/cli/task/import.rb", "lib/ghost/cli/task/list.rb", "lib/ghost/cli/task/set.rb", "lib/ghost/host.rb", "lib/ghost/store", "lib/ghost/store.rb", "lib/ghost/store/dscl_store.rb", "lib/ghost/store/hosts_file_store.rb", "lib/ghost/tokenized_file.rb", "lib/ghost/version.rb", "spec/ghost", "spec/ghost/cli", "spec/ghost/cli/task", "spec/ghost/cli/task/add_spec.rb", "spec/ghost/cli/task/delete_spec.rb", "spec/ghost/cli/task/empty_spec.rb", "spec/ghost/cli/task/export_spec.rb", "spec/ghost/cli/task/help_spec.rb", "spec/ghost/cli/task/import_spec.rb", "spec/ghost/cli/task/list_spec.rb", "spec/ghost/cli_spec.rb", "spec/ghost/host_spec.rb", "spec/ghost/store", "spec/ghost/store/dscl_store_spec.rb", "spec/ghost/store/hosts_file_store_spec.rb", "spec/ghost/store_spec.rb", "spec/ghost/tokenized_file_spec.rb", "spec/spec_helper.rb", "spec/support", "spec/support/cli.rb", "spec/support/resolv.rb"]
  s.homepage = "http://github.com/bjeanes/ghost"
  s.licenses = ["MIT"]
  s.rubyforge_project = "ghost"
  s.rubygems_version = "2.2.2"
  s.summary = "Allows you to create, list, and modify local hostnames"
  s.test_files = ["spec/ghost", "spec/ghost/cli", "spec/ghost/cli/task", "spec/ghost/cli/task/add_spec.rb", "spec/ghost/cli/task/delete_spec.rb", "spec/ghost/cli/task/empty_spec.rb", "spec/ghost/cli/task/export_spec.rb", "spec/ghost/cli/task/help_spec.rb", "spec/ghost/cli/task/import_spec.rb", "spec/ghost/cli/task/list_spec.rb", "spec/ghost/cli_spec.rb", "spec/ghost/host_spec.rb", "spec/ghost/store", "spec/ghost/store/dscl_store_spec.rb", "spec/ghost/store/hosts_file_store_spec.rb", "spec/ghost/store_spec.rb", "spec/ghost/tokenized_file_spec.rb", "spec/spec_helper.rb", "spec/support", "spec/support/cli.rb", "spec/support/resolv.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<unindent>, ["= 1.0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.3.3"])
      s.add_development_dependency(%q<rake>, ["= 0.9.2.2"])
    else
      s.add_dependency(%q<unindent>, ["= 1.0"])
      s.add_dependency(%q<minitest>, ["~> 5.3.3"])
      s.add_dependency(%q<rake>, ["= 0.9.2.2"])
    end
  else
    s.add_dependency(%q<unindent>, ["= 1.0"])
    s.add_dependency(%q<minitest>, ["~> 5.3.3"])
    s.add_dependency(%q<rake>, ["= 0.9.2.2"])
  end
end
