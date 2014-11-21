# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Wint::Application.load_tasks

namespace :wint do
  ##--  WinT
  desc "Start WinT"
  task(:start) do
    env = ENV['RAILS_ENV'] || "production"
    sh "RAILS_ENV=#{env} bundle exec rake assets:precompile RAILS_RELATIVE_URL_ROOT=/App/GameExrc/WinT"
    Rake::Task["wint:unicorn:start"].invoke
    Rake::Task["wint:sidekiq:start"].invoke
  end

  desc "Stop WinT"
  task(:stop) do
    Rake::Task["wint:unicorn:stop"].invoke
    Rake::Task["wint:sidekiq:stop"].invoke
  end

  desc "Restart WinT"
  task(:restart) do
    Rake::Task["wint:unicorn:restart"].invoke
    Rake::Task["wint:sidekiq:restart"].invoke
  end

  desc "Status WinT"
  task(:status) do
    Rake::Task["wint:unicorn:status"].invoke
    Rake::Task["wint:sidekiq:status"].invoke
  end

  ##--  Unicorn
  namespace :unicorn do
    desc "Start unicorn"
    task(:start) do
      unicorn_config = rails_root + "/config/unicorn.rb"
      env = ENV['RAILS_ENV'] || "production"
      sh "bundle exec unicorn_rails -D -c #{unicorn_config} -E #{env} --path /App/GameExrc/WinT"
    end

    desc "Stop unicorn"
    task(:stop) do
      unicorn_signal :QUIT
    end

    desc "Restart unicorn"
    task(:restart) do
      Rake::Task["wint:unicorn:stop"].invoke
      Rake::Task["wint:unicorn:start"].invoke
    end

    desc "Status unicorn"
    task(:status) do
      puts "-*-  unicorn status -*-"
      print_status unicorn_pid
    end
  end

  ##--  Sidekiq
  namespace :sidekiq do
    desc "Start sidekiq"
    task(:start) do
      sidekiq_config = rails_root + "/config/sidekiq.yml"
      env = ENV['RAILS_ENV'] || "production"
      sh "RAILS_ENV=#{env} bundle exec sidekiq -d -C #{sidekiq_config}"
    end

    desc "Stop sidekiq"
    task(:stop) do
      sidekiq_signal :QUIT
    end

    desc "Restart sidekiq"
    task(:restart) do
      Rake::Task["wint:sidekiq:stop"].invoke
      Rake::Task["wint:sidekiq:start"].invoke
    end

    desc "Status sidekiq"
    task(:status) do
      puts "-*-  sidekiq -*-"
      print_status sidekiq_pid
    end
  end

  ##--  Helper
  def unicorn_signal(signal)
    pid = unicorn_pid
    Process.kill signal, pid if pid
  end

  def sidekiq_signal(signal)
    pid = sidekiq_pid
    Process.kill signal, pid if pid
    sh "rm #{rails_root}/tmp/pids/sidekiq.pid" if pid
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

