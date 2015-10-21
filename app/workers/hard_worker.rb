
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)
    stdout = submit.perform
    return unless stdout
    game_log, result = stdout.split(/\r\n\r\n|\n\n/)

    submit.update(analysis_file: "#{submit.data_dir}/analy/analy.json")
    AnalysisManager.create(submit.data_dir, game_log, result)
    analy = AnalysisManager.new(submit.analysis_file)
    analy.update

    submit.player.update(submit_id: submit.id) # if strategy.best?
    # strategy = Strategy.create(submit, game_log, result)
    # strategy.submit.player.update(submit_id: submit.id) if strategy.best?
  end
end

