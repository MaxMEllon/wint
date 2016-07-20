require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'sidekiq/testing'
require 'pry-rails'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.order = 'random'

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  Sidekiq::Testing.inline!

  Capybara.default_max_wait_time = 5
  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: true)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    stub_const('League::BASE_PATH', "#{Rails.root}/tmp/data")
    `rm -rf #{Rails.root}/tmp/data`
    `mkdir -p #{Rails.root}/tmp/data`
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each, js: true) do
    wait_for_ajax
  end
end

