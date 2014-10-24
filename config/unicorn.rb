listen 55010

preload_app true
worker_processes 8

pid "tmp/pids/unicorn.pid"
stdout_path "log/unicorn.stdout.log"
stderr_path "log/unicorn.stderr.log"
Unicorn::Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

