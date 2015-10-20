module WaitForAction
  SLEEP_TIME = 1.0

  def wait_for_action(time = SLEEP_TIME)
    sleep time
  end
end

RSpec.configure do |config|
  config.include WaitForAction
end

