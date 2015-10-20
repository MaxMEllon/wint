module WaitForAction
  SLEEP_TIME = 0.3

  def wait_for_action(time = SLEEP_TIME)
    time = time * 2 if ENV['CIRCLECI']
    sleep time
  end
end

RSpec.configure do |config|
  config.include WaitForAction
end

