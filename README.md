## 1 - Install Bitcoin Daemon
```
$ sudo add-apt-repository ppa:bitcoin/bitcoin
$ sudo apt-get update
$ sudo apt-get install bitcoind
```
Run the the daemon and stop:
```
$ bitcoind
$ bitcoin-cli stop
```
Now paste the following configs in `~/.bitcoin/bitcoin.conf`:
```
prune=600
maxconnections=12
maxuploadtarget=30
rpcuser=user
rpcpassword=password
rpcallowip=127.0.0.1
rpcport=8332
daemon=1
server=1
keypool=10000
walletnotify=curl "https://api.guessgoals.com/notify/%s"
```
Run the daemon again:
```
$ bitcoind
```
Now you have to wait for it to sync with the bitcoin network. Check the progress:
```
$ tail -f ~/.bitcoin/debug.log
```

You can make this a systemd service using [This systemd-service File](https://gist.github.com/mefeghhi/2f74f0e0837ffee49db2e0a4c568ddd5)

## 2 - Install Node using NVM
```
$ sudo apt-get update
$ sudo apt-get install build-essential libssl-dev
```
Find the latest version [here](https://github.com/nvm-sh/nvm/releases) and change the version in the curl command below:
```
$ cd
$ curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh -o install_nvm.sh
```
Run the installation script: (This will also add necessary lines to `~/.profile`)
```
$ bash install_nvm.sh
```

Reload the `~/.profile` source file:
```
$ source ~/.profile
```

```
$ nvm ls-remote
```

Find the latest LTS version, install it and make it default (If you only have one version, it is already default)
```
$ nvm install x.y.z
$ nvm ls
$ nvm alias default x.y.z
$ node -v
$ npm -v
```

Read [Install Node Using PPA](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04)

## 3 - Install Yarn
```
$ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
$ echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$ sudo apt-get update && sudo apt-get install yarn
```

## 4 - Install Redis
```
$ sudo apt-get install redis-server
```
Open `/etc/redis/redis.conf` and uncoment `requirepass foobared` and restart the service.
If you are accessing redis from outside, you also have to modify `bind` command with `bind 0.0.0.0 ::0`

## 5 - Install Postgresql
```
$ sudo apt-get install libpq-dev
$ sudo apt-get install postgresql postgresql-contrib
```

Open `/etc/postgresql/<VERSION>/main/pg_hba.conf` and Change `peer` to `trust` for `local all postgres` and `local all all` then do a `sudo service postgresql restart`:
```
$ psql -U postgres
postgres=# CREATE ROLE gg_prod_db_user WITH LOGIN CREATEDB PASSWORD 'the_password';
postgres=# CREATE DATABASE gg_prod_db;
postgres=# GRANT ALL PRIVILEGES ON DATABASE gg_prod_db TO gg_prod_db_user;
```

After this, revert the changes in `pg_hba.conf` file from `trust` to `md5` and restart postgresql.
If you are accessing redis from outside, you also have to modify `bind` command with `0.0.0.0 ::0`

## 6 - Install RVM
```
$ sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
$ curl -sSL https://get.rvm.io | bash -s stable
$ source ~/.rvm/scripts/rvm
```

## 7 - Install Ruby with jemalloc
By sept 2019, ruby 2.6.3 does not support jemalloc.
```
$ sudo apt install libjemalloc-dev
$ rvm install 2.5.5 -C --with-jemalloc
$ ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
```

## 8 - Setup capistrano (Backend)
### On Server
- Make an ubuntu user to use for deployment or use an existing one.
```
$ sudo adduser deploy
$ sudo adduser deploy sudo
$ su deploy
```
- Install ca-certificates, nginx, curl, git 
```
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
$ sudo apt-get install -y apt-transport-https ca-certificates curl git-core nginx -y
```
- Now Nginx is a service
```
$ sudo service nginx start|stop|restart|status
$ sudo systemctl start|stop|restart|status nginx
```
- Install rails and bundler
```
$ gem install bundler
$ gem install rails -v 6.0.0 --no-document
```
- Make a SSH key
```
$ ssh-keygen -t rsa
Enter This name: /home/deploy/.ssh/#{appname}_rsa
```
- Print this key, and add it to your repo keys
```
$ cat /home/deploy/.ssh/#{appname}_rsa.pub
```
- Open `~/.ssh/config` and put the following line
```
IdentityFile ~/.ssh/#{appname}_rsa
```
- Check if your access is set:
```
$ ssh -T git@github.com
or
$ ssh -T git@bitbucket.org
```

- Add the following to `/lib/systemd/system/sidekiq.service`:
```
[Unit]
Description=sidekiq
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/home/ubuntu/apps/backend/current
ExecStart=/bin/bash -lc 'bundle exec sidekiq -e production -C config/sidekiq.yml'
User=ubuntu
Group=ubuntu
UMask=0002

Environment=MALLOC_ARENA_MAX=2
EnvironmentFile=/etc/environment
RestartSec=1
Restart=always

# output goes to /var/log/syslog
StandardOutput=syslog
StandardError=syslog

# This will default to "bundler" if we don't specify it
SyslogIdentifier=sidekiq

[Install]
WantedBy=multi-user.target
```
Then do:
```
$ sudo systemctl enable sidekiq
```

### On your local machine
- Add to your gem file
```
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'ed25519', '~> 1.2'
  gem 'bcrypt_pbkdf', '~> 1'
end
```
- Bundle
```
$ bundle install
```
- create capistrano files
```
cap install
```
- Edit Capfile and paste
```
require 'capistrano/setup'
require 'capistrano/deploy'
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/puma'
install_plugin Capistrano::Puma
require 'capistrano/yarn'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```
- Paste the following in `config/deploy.rb` and edit server_path, repo_url, application_name, workers, threads, user, and path for the key used for ssh:
```ruby
# Change these
server '54.194.35.48', port: 22, roles: [:web, :app, :db], primary: true

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
      puts capture("pgrep -f 'sidekiq' | xargs kill -TSTP") 
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
```
- Edit your firewall to let incoming connection to port 22 (80 and 443) 
- Create file `config/nginx.conf` and paste the following and edit `appname`
```
upstream puma {
  server unix:///home/ubuntu/apps/backend/shared/tmp/sockets/backend-puma.sock;
}
upstream frontend {
  server 127.0.0.1:5000;
}

# Frontend - NextJS
server {
  listen 80 default_server deferred;
  server_name guessgoals.com www.guessgoals.com;

  root       /home/ubuntu/apps/frontend/current/dist/static;
  access_log /home/ubuntu/apps/frontend/current/log/nginx.access.log;
  error_log  /home/ubuntu/apps/frontend/current/log/nginx.error.log info;

  location ^~ /static {
    root /home/ubuntu/apps/frontend/current;
    gzip_static on;
    expires 30d;
    add_header Vary Accept-Encoding;
    add_header Cache-Control "public";
  }
  
  location ^~ /_next {
    rewrite ^/_next(.*)$ $1;
    root /home/ubuntu/apps/frontend/current/dist;
    gzip_static on;
    expires 30d;
    add_header Vary Accept-Encoding;
    add_header Cache-Control "public";
	}

  try_files $uri @frontend;
  
  location @frontend {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    proxy_pass http://frontend;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}

# API - Rails
server {
  listen 80;
  server_name api.guessgoals.com;

  root       /home/ubuntu/apps/backend/current/public;
  access_log /home/ubuntu/apps/backend/current/log/nginx.access.log;
  error_log  /home/ubuntu/apps/backend/current/log/nginx.error.log info;

  location ^~ /assets {
    gzip_static on;
    expires 30d;
    add_header Vary Accept-Encoding;
    add_header Cache-Control "public";
  }

  location ^~ /packs {
    gzip_static on;
    expires 30d;
    add_header Vary Accept-Encoding;
    add_header Cache-Control "public";
  }
  
  location /cable {
    proxy_pass http://puma;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  try_files $uri/index.html $uri @puma;
  
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```
- Issue deploy command from development machine
```
$ cap production deploy:initial
```

### On Server
- Create a shortcut or (symbolic link) to `config/nginx.conf` in `sites-enabled` 
```
$ sudo rm /etc/nginx/sites-enabled/default
$ sudo ln -nfs "/home/ubuntu/apps/backend/current/config/nginx.conf" "/etc/nginx/sites-enabled/ggprod"
```
- Restart Nginx
```
$ sudo systemctl restart nginx
$ sudo journalctl -u nginx.service -f (logging live a service with name)
```
You should now be able to point your web browser to your server IP and see your Rails app in action!
- If you make change to `config/nginx.conf`, commit, issue a deploy command: `$ cap production deploy` and restart nginx on the server: `sudo service nginx restart`
- Add environment variables to `/etc/environment`:
```
RAILS_ENV=""
RAILS_MAX_THREADS=""
WEB_CONCURRENCY=""
REDIS_URL=""
AUTH_PRIVATE_KEY=""
SECRET_KEY_BASE=""
PROD_DB=""
PROD_DB_USER=""
PROD_DB_USER_PASS=""
BITCOIN_RPC_IP=""
BITCOIN_RPC_IP=""
BITCOIN_RPC_USER=""
BITCOIN_RPC_PASS=""
SENTRY_RAILS_WEBHOOK_URL=""
SMPT_USER=""
SMTP_PASS=""
```

## 8 - Setup capistrano (Frontend)
```
$ sudo apt-get install libpng-dev
$ npm install -g pm2
```
Create a `Gemfile` in frontend directory:
```
source 'https://rubygems.org'

gem 'capistrano', '~> 3.9.1'
gem 'capistrano-nvm', '~> 0.0.7'
gem 'ed25519', '~> 1.2'
gem 'bcrypt_pbkdf', '~> 1'
```
Then do:
```
$ bundle
$ cap install
```

Change your Capfile content:
```
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
require 'capistrano/nvm'
install_plugin Capistrano::SCM::Git
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

Copy in `config/deploy.rb`
```

server '54.194.35.48', user: 'ubuntu', roles: 'app', primary: true

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
```

```
$ cap production deploy:initial
$ cap production deploy
```

[reference](http://jameshuynh.com/nextjs/react/capistrano/nvm/pm2/2017/10/07/deploy-nextjs-app-with-capistrano-3-nvm-and-pm2/)

## Setting up HTTPS
```
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx
$ sudo certbot --nginx -d guessgoals.com -d www.guessgoals.com -d api.guessgoals.comc
```

## Install youtube-dl
```
$ sudo apt-get install youtube-dl
$ sudo apt install python3
$ sudo apt install python3-pip
```
