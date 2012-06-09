RAILS_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))

require "bundler/capistrano"

# use local key for authentication
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :application, "mugglein"
set :deploy_to, "/var/www/mugglein"
set :repository,  "git@github.com:mhayes/mugglein.git"
set :branch, "master"

set :deploy_via, :remote_cache
set :scm, "git"
set :use_sudo, false
set :user, "mugglein"

server = "muggle.in"
role :app, server
role :web, server
role :db, server, :primary => true
set :rails_env, 'production'

before "deploy:assets:precompile", "deploy:link_config_files"
after "deploy:update_code", "deploy:link_config_files"
after "deploy:restart", "unicorn:reload"
# after "deploy:restart", "delayed_job:restart"

set :keep_releases, 3
after "deploy:update", "deploy:cleanup"

namespace :deploy do
  desc "Symlink production config files"
  task :link_config_files do
    config_files = Dir.glob(Pathname.new(RAILS_ROOT).join("config", "*.yml.sample"))
    config_files.each do |file|
      f = File.basename(file, ".yml.sample")
      run "ln -nfs #{shared_path}/config/#{f}.yml #{release_path}/config/#{f}.yml" 
    end
    
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  end
end

set :unicorn_binary, "/usr/bin/unicorn"
set :unicorn_pid, "/tmp/unicorn.mugglein.pid"
namespace :unicorn do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{unicorn_binary} -c config/unicorn.rb -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end

# namespace :delayed_job do
#   desc "Start delayed_job"
#   task :start do
#     run "sudo start dj_mugglein"
#   end
#   
#   desc "Stop delayed_job"
#   task :stop do
#     run "sudo stop dj_mugglein"
#   end
#   
#   desc "Restart delayed_job"
#   task :restart do
#     run "sudo restart dj_mugglein"
#   end
# end
