
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)
    submit.filecheck rescue return
    submit.compile rescue return
    submit.execute rescue return
    submit.update(status: Submit::Status::SUCCESS)
    strategy = Strategy.create(submit)
    strategy.submit.player.update(submit_id: submit.id) if strategy.best?
  end
end

