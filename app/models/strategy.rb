class Strategy < ActiveRecord::Base
  belongs_to :submit
  has_one :player, through: :submit

  scope :score_by, -> { order("score DESC") }

  RANK = {0...30 => "X", 30...35 => "C", 35...40 => "B", 40...45 => "A", 45...50 => "S", 50...75 => "SS", 75..100 => "SSS"}

  # Analysisクラスを作るまではごちゃごちゃしてるけど仕方ない

  # override
  def self.create(submit)
    analy_file = Strategy.mkdir(submit)
    score = File.read(submit.data_dir + "/analy/result/Result.txt").split.last.to_f
    super(submit_id: submit.id, analy_file: analy_file, score: score, number: Strategy.get_number(submit))
  end

  def best?
    strategies = self.submit.player.strategies.score_by
    return true if strategies.blank? || self.score >= strategies.first.score
    false
  end

  def rank
    RANK.each do |range, rank|
      return rank if range.include?(self.achievement)
    end
  end

  def achievement
    (self.score / self.submit.player.league.limit_score) * 100
  end

  private
  def self.mkdir(submit)
    path = submit.data_dir + "/analy"
    Dir::mkdir(path)
    Dir::mkdir(path + "/code")
    Dir::mkdir(path + "/result")
    Dir::mkdir(path + "/log")
    `mv #{Rails.root}/tmp/log/_tmp/Result.txt #{path}/result`
    `mv #{Rails.root}/tmp/log/_tmp/Game.log #{path}/log`
    `touch #{path}/analy.json`
    path + "/analy.json"
  end

  def self.get_number(submit)
    strategies = submit.player.strategies
    strategies.present? ? strategies.last.number+1 : 1
  end
end

