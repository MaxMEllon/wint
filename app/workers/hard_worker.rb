
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)
    stdout = submit.perform
    return unless stdout
    log, result = stdout.split(/\r\n\r\n|\n\n/)

    source = MyFile.new(path: submit.src_file)
    analysis = AnalysisManager.create(
      path: submit.analysis_dirname,
      code: source.data,
      adlint: source.data,
      log: log,
      result: result
    )
    submit.update(analysis_file: analysis.path)

    submit.player.update(submit_id: submit.id) if submit.best?
  end
end

