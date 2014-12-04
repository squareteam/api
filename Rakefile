require 'rubygems'

# Load the App
require File.expand_path '../api', __FILE__

require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'rdoc/task'

# Configure Rspec rake tasks
RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  task.pattern    = 'spec/**/*_spec.rb'
end

# Rdoc rake task
desc 'generate API documentation to doc/rdocs/index.html'
RDoc::Task.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.txt'
  rd.rdoc_files.include 'README.md', "config/**/*\.rb", "app/**/*\.rb", "lib/**/*\.rb"

  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--all'
  rd.options << '--fileboxes'
  rd.options << '--diagram'
end

# ST rake tasks
Dir.glob('lib/tasks/*.rake').each do |r|
  load r
end

# DEV run server
task :run do
  ENV['ST_PORT'] ||= '8000'
  ENV['ST_HOST'] ||= 'localhost'
  `bundle exec rackup -p #{ENV['ST_PORT']} -o #{ENV['ST_HOST']}`
end

# DEV run console
task :c => :console
task :console do
  require 'pry'
  ARGV.clear
  Pry.start
end

task :spec => 'ci:setup:rspec'
task :default => :spec
