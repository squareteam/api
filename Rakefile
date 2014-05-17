require 'rubygems'

# Load the App
require File.expand_path '../api', __FILE__

require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  task.pattern    = 'spec/**/*_spec.rb'
end

# ST rake tasks
Dir.glob('lib/tasks/*.rake').each do |r|
  load r
end

task :run do
  ENV['ST_PORT'] ||= '8000'
  ENV['ST_HOST'] ||= 'localhost'
  `bundle exec rackup -p #{ENV['ST_PORT']} -o #{ENV['ST_HOST']}`
end

task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :default => :spec
