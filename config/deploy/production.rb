set :deploy_to, '/home/vagrant/wint'
set :ssh_options,
  keys: [File.expand_path('~/private_key')],
  forward_agent: true,
  auth_methods: %w(publickey)

