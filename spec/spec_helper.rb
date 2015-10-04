require 'database_cleaner'
require 'fakefs/spec_helpers'
require 'sidekiq/testing'

RSpec.configure do |config|
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {js_errors: false})
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Capybara::DSL
  config.include FakeFS::SpecHelpers, fakefs: true

  config.before do
    allow(ModelHelper).to receive(:data_root).and_return("#{Rails.root}/tmp/data")
    FileUtils.mkdir "#{Rails.root}/tmp" unless File.exist?("#{Rails.root}/tmp")
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    FileUtils.rm_rf "#{Rails.root}/tmp/data" if File.exist?("#{Rails.root}/tmp/data")
    FileUtils.mkdir "#{Rails.root}/tmp/data"
  end

  config.after(:each) do
    DatabaseCleaner.clean
    FileUtils.rm_rf "#{Rails.root}/tmp/data"
  end

  Sidekiq::Testing.inline!
end

