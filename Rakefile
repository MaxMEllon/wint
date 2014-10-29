# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Wint::Application.load_tasks

namespace :wint do
  ##--  Task
  desc "Start unicorn & sidekiq"
  task(:start) do
    unicorn_config = rails_root + "/config/unicorn.rb"
    sidekiq_config = rails_root + "/config/sidekiq.yml"
    env = ENV['RAILS_ENV'] || "production"
    sh "RAILS_ENV=#{env} bundle exec rake assets:precompile RAILS_RELATIVE_URL_ROOT=/App/GameExrc/WinT"
    sh "bundle exec unicorn_rails -D -c #{unicorn_config} -E #{env} --path /App/GameExrc/WinT"
    sh "RAILS_ENV=#{env} bundle exec sidekiq -d -C #{sidekiq_config}"
  end

  desc "Stop unicorn & sidekiq"
  task(:stop) do
    unicorn_signal :QUIT
    sidekiq_signal :QUIT
  end

  desc "Restart unicorn & sidekiq"
  task(:restart) do
    Rake::Task["wint:stop"].invoke
    Rake::Task["wint:start"].invoke
  end

  desc "Status unicorn & sidekiq"
  task(:status) do
    puts "-*-  unicorn -*-"
    print_status unicorn_pid
    puts "-*-  sidekiq -*-"
    print_status sidekiq_pid
  end

  ##--  Helper
  def unicorn_signal(signal)
    Process.kill signal, unicorn_pid
  end

  def sidekiq_signal(signal)
    Process.kill signal, sidekiq_pid
    sh "rm #{rails_root}/tmp/pids/sidekiq.pid"
  end

  def unicorn_pid
    return nil unless File.exist?(rails_root + "/tmp/pids/unicorn.pid")
    File.read(rails_root + "/tmp/pids/unicorn.pid").to_i
  end

  def sidekiq_pid
    return nil unless File.exist?(rails_root + "/tmp/pids/sidekiq.pid")
    File.read(rails_root + "/tmp/pids/sidekiq.pid").to_i
  end

  def print_status(pid)
    if pid.blank?
      puts "Status stop"
    else
      puts "Status running..."
      puts pid
    end
  end

  def rails_root
    File.expand_path(File.dirname(__FILE__))
  end
end
