# Change these
server '176.34.141.129', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:meysius/guessgoals.git'
set :repo_tree,       'backend'
set :application,     'backend'
set :user,            'ubuntu'
set :puma_threads,    [2, 4]
set :puma_workers,    2

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/gg_meysam) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
# set :scm,           :git
set :branch,        :master
set :format,        :pretty
set :log_level,     :info
set :keep_releases, 2

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Compile Webpack'
  task :compile_webpack do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && RAILS_ENV=production ~/.rvm/bin/rvm default do bundle exec rake webpacker:compile")
      end
    end
  end

  before :starting,       :check_revision
  after  :finishing,      :compile_assets
  after  :compile_assets, :compile_webpack
  after  :finishing,      :cleanup
end

# ps aux | grep puma    # Get puma pid

# Normal or Hot Restart puma (Requests will hang, safe for migrations)
# kill -s SIGUSR2 pid    
# pumactl restart

# Phased Restart (Zero Downtime, unsafe when u have migrations)
# kill -s SIGUSR1 pid
# pumactl phased-restart

# Stop puma
# kill -s SIGTERM pid

namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'sidekiq' | sudo xargs kill -TSTP") 
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'



