require File.dirname(__FILE__) + '/rake_helper'

desc "Create READMEs from README.mkdn"
task :readme do
  require 'rdiscount'
  readme = File.read('README.mkdn')
  readme_html = RDiscount.new(readme).to_html
  File.open('README.html', 'w') do |f|
    puts "Writing out HTML file"
    f.write readme_html
  end  
  
  File.open('README', 'w') do |f|
    puts "Writing out text file"
    f.write readme
  end
end
