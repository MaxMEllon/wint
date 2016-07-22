
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    @submit = Submit.where(id: submit_id).first
    @submit.perform
    if @submit.exec_success?
      strategy = Strategy.create(@submit)
      strategy.submit.player.update(submit_id: @submit.id) if strategy.best?
    end
  end
end

