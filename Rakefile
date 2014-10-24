# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Wint::Application.load_tasks

namespace :unicorn do
  ##--  Task
  desc "Start unicorn"
  task(:start) do
    config = rails_root + "/config/unicorn.rb"
    env = ENV['RAILS_ENV'] || "production"
    sh "bundle exec unicorn_rails -D -c #{config} -E #{env} --path /App/GameExrc/WinT"
  end

  desc "Stop unicorn"
  task(:stop) { unicorn_signal :QUIT }

  desc "Restart unicorn"
  task(:restart) do
    Rake::Task["unicorn:stop"].invoke
    Rake::Task["unicorn:start"].invoke
  end

  desc "Status unicorn"
  task(:status) do
    pid = unicorn_pid
    if pid.blank?
      puts "Status stop"
    else
      puts "Status running..."
      puts pid
    end
  end

  ##--  Helper
  def unicorn_signal(signal)
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    return nil unless File.exist?(rails_root + "/tmp/pids/unicorn.pid")
    File.read(rails_root + "/tmp/pids/unicorn.pid").to_i
  end

  def rails_root
    File.expand_path(File.dirname(__FILE__))
  end
end
