require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'

Dir['tasks/**/*.rake'].each { |rake| load rake }


#### MISC TASKS ####

desc "list tasks"
task :default do
  puts `rake -T`.grep(/^[^(].*$/)
end

desc "Outstanding TODO's"  
task :todo do  
  files = ["**/*.{rb,rake}" "bin/*", "README.mkdn"]
  
  File.open('TODO','w') do |f|
      FileList[*files].egrep(/TODO|FIXME/) do |file, line, text|
      output = "#{file}:#{line} - #{text.chomp.gsub(/^\s+|\s+$/ , "")}"
    
      puts output
      f.puts output
    end
  end
end