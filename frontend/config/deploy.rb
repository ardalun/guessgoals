
server '176.34.141.129', user: 'ubuntu', roles: 'app', primary: true

set :repo_url,      'git@github.com:meysius/guessgoals.git'
set :application,   'frontend'
set :repo_tree,     'frontend'
set :user,          'ubuntu'
set :server_name,   'guessgoals.com'

set :stage,         :production
set :branch,        'master'
set :keep_releases, 3
set :deploy_to,     "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/gg_meysam) }

# for NVM
set :nvm_node,        'v10.16.3'
set :nvm_type,        :user
set :nvm_map_bins,    %w[node npm yarn pm2 next]
set :nvm_custom_path, "/home/#{fetch(:user)}/.nvm/versions/node"
set :default_env,     'PATH' => "/home/#{fetch(:user)}/.nvm/versions/node/v10.16.3/bin:$PATH"
set :nvm_path,        "/home/#{fetch(:user)}/.nvm"

# share node_modules folder
set :linked_dirs, %w[node_modules]

namespace :deploy do
  after 'deploy:publishing', 'deploy:build'
  after 'deploy:publishing', 'deploy:restart'

  task :initial do
    on roles(:app) do
      within current_path do
        execute :npm, 'start'
        execute :npm, 'stop'
        invoke 'deploy'
      end
    end
  end

  task :build do
    on roles(:app) do
      within current_path do
        execute :npm, 'run build'
      end
    end
  end

  task :restart do
    on roles(:app) do
      within current_path do
        execute :npm, 'stop'
        execute :npm, 'start'
      end
    end
  end

  task :start do
    on roles(:app) do
      within current_path do
        execute :npm, 'start'
      end
    end
  end

  task :stop do
    on roles(:app) do
      within current_path do
        execute :npm, 'stop'
      end
    end
  end
end