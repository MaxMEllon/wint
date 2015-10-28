
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)
    stdout = submit.perform
    return unless stdout
    log, result = stdout.split(/\r\n\r\n|\n\n/)

    analysis = AnalysisManager.create(
      path: submit.analysis_dirname,
      code: MyFile.new(path: submit.src_file).data,
      log: log,
      result: result
    )
    submit.update(analysis_file: analysis.path)

    submit.player.update(submit_id: submit.id) # if strategy.best?
    # strategy = Strategy.create(submit, game_log, result)
    # strategy.submit.player.update(submit_id: submit.id) if strategy.best?
  end
end

