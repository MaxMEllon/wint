# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'wint'
# set :repo_url, 'git@github.com:gembaf/wint.git'
set :repo_url, 'https://github.com/gembaf/wint.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, 'cap_test'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/home/vagrant/deploy/wint'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :rbenv_type, :system
set :rbenv_ruby, '2.2.2'

set :bundle_flags, '--deployment --without development test'

server "#{server_name}", user: 'vagrant', port: 2002, roles: %w(web app db)

namespace :deploy do

  task :db_create do
    on roles(:db) do |host|
      within current_path do
        execute :bundle, :exec, :rake, 'db:create RAILS_ENV=production'
      end
    end
  end

  # task :restart do
  #   on roles(:app) do
  #     invoke 'unicorn:restart'
  #   end
  # end

  # after :publishing, :restart
end

