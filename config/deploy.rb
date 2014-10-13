require 'mina/bundler'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :user, '542f2dbd5973ca91100006bf'
set :domain, 'alpha.squareteam.io'
set :deploy_to, "/var/lib/openshift/#{user}/app-root/data"
set :current_dir, "/var/lib/openshift/#{user}/app-root/runtime/repo"
set :repository, 'git@bitbucket.org:squareteam/api-sinatra.git'
set :branch, 'master'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
#set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
  set :bash_env, 'RACK_ENV=production'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
#  queue! %[mkdir -p "#{deploy_to}/shared/log"]
#  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

#  queue! %[mkdir -p "#{deploy_to}/shared/config"]
#  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

#  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
#  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc 'Starts an interactive console on the server'
task :console => :environment do
  in_directory current_dir do
    queue echo_cmd %[#{bash_env} bundle exec ./console && exit]
  end
end

namespace :db do
  desc 'Launch migrations on the database'
  task :migrate => :environment do
    in_directory current_dir do
      queue! %[bundle exec rake db:migrate "#{bash_env}"]
    end
  end

  namespace :migrate do
    desc 'Check migration status'
    task :status => :environment do
      in_directory current_dir do
        queue! %[bundle exec rake db:migrate:status "#{bash_env}"]
      end
    end
  end
end

namespace :deploy do

  # * echoes the command in verbose mode
  # * executes the command in non simulate mode
  # * fails deployment if command return code != 0
  def local_queue(cmd)
    say "$ #{cmd}" if verbose_mode?
    ok = system cmd unless simulate_mode?
    fail "** '#{cmd}' command failed" unless ok
  end

  desc 'Only copy frontend files to deployment'
  task :front => :environment do
    set :destination, "#{current_dir}/public/"

    ssh_opts = ''
    ssh_opts += " -P #{port}" if port
    ssh_opts += " -i #{identity_file}" if identity_file
    ssh_opts += ' -r'

    local_queue "echo '-----> Uploading files to #{destination} directory'"
    local_queue "scp #{ssh_opts} public/* #{user}@#{domain}:#{destination}"
  end
end

namespace :log do
  desc 'Output and follow application logs'
  task :tail => :environment do
    in_directory current_dir do
      queue! %[tail -f log/production.err.log]
    end
  end
end

namespace :passenger do
  desc 'Restart passenger'
  task :restart => :environment do
    queue! %[touch "#{current_dir}/tmp/restart.txt"]
  end

  desc 'Passenger status'
  task :status => :environment do
    queue! %[passenger-status]
  end
end
