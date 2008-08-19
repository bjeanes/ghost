require File.dirname(__FILE__) + '/rake_helper'

desc "Run the gem's binary command (for testing)"
task :run do
  `/usr/bin/env ruby -rlib/ghost bin/ghost`
end
