# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'depot'
set :user, 'halcyon'
set :repo_url, "git@github.com:fengt/#{fetch(:application)}.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:user)}/deploy/depot"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :airbrussh.
set :format, :airbrussh

# Defaults to false
# Skip migration if files in db/migrate were not modified
set :conditionally_migrate, true

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'bin', 'vendor/bundle'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3


namespace :deploy do
  
  commands = [:start, :stop, :restart]

  commands.each do |command|
    desc "thin #{command}"
    task command do
      on roles(:app), in: :sequence, wait: 5 do
        within current_path do
          execute :bundle, "exec thin #{command} -C #{fetch(:thin_config)}"
        end
      end
    end
  end

  after :finishing, 'deploy:cleanup'

end
after 'deploy:publishing', 'deploy:restart'