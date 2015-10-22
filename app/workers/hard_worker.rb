
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)
    stdout = submit.perform
    return unless stdout
    log, result = stdout.split(/\r\n\r\n|\n\n/)

    submit.update(analysis_file: "#{submit.data_dir}/analy/analy.json")

    FileUtils.mkdir(submit.data_dir + '/analy')
    # FileUtils.mkdir(submit.data_dir + '/analy/result')
    # FileUtils.mkdir(submit.data_dir + '/analy/code')
    # FileUtils.mkdir(submit.data_dir + '/analy/log')

    AnalysisManager.create(
      path: submit.data_dir,
      code: MyFile.new(path: submit.src_file),
      log: MyFile.new(data: log),
      result: MyFile.new(data: result)
    )
    analy = AnalysisManager.new(submit.analysis_file)
    analy.update

    submit.player.update(submit_id: submit.id) # if strategy.best?
    # strategy = Strategy.create(submit, game_log, result)
    # strategy.submit.player.update(submit_id: submit.id) if strategy.best?
  end
end

