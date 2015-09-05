module WaitForAction
  SLEEP_TIME = 0.5

  def wait_for_action
    sleep SLEEP_TIME
  end
end

RSpec.configure do |config|
  config.include WaitForAction
end

