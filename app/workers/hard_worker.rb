
class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(submit_id)
    submit = Submit.find(submit_id)

    tmp_path = "#{Rails.root}/tmp/log/_tmp#{submit_id}"
    FileUtils.mkdir("#{Rails.root}/tmp/log") unless File.exist?("#{Rails.root}/tmp/log")
    FileUtils.mkdir(tmp_path) unless File.exist?(tmp_path)

    stdout = submit.perform

    return unless stdout
    game_log, result = stdout.split(/\r\n\r\n|\n\n/)
    File.open(tmp_path + '/Game.log', 'w') { |f| f.puts game_log }
    File.open(tmp_path + '/Result.txt', 'w') { |f| f.puts result }

    strategy = Strategy.create(submit)
    strategy.submit.player.update(submit_id: submit.id) if strategy.best?
  end
end

