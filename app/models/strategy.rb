require "analysis/analysis_manager"

class Strategy < ActiveRecord::Base
  belongs_to :submit
  has_one :player, through: :submit
  has_one :league, through: :player

  scope :score_by, -> { order("score DESC") }

  RANK = {0...30 => "X", 30...35 => "C", 35...40 => "B", 40...45 => "A", 45...50 => "S", 50...75 => "SS", 75..100 => "SSS"}

  # override
  def self.create(submit)
    analy_file = AnalysisManager.create(submit.data_dir)
    analy = AnalysisManager.new(analy_file)
    analy.update
    super(submit_id: submit.id, analy_file: analy_file, score: analy.result.score, number: Strategy.get_number(submit))
  end

  def analysis_update
    AnalysisManager.new(self.analy_file).update
  end

  def best?
    strategies = self.submit.player.strategies.score_by
    return true if strategies.blank? || self.score >= strategies.first.score
    false
  end

  private
  def self.get_number(submit)
    strategies = submit.player.strategies
    strategies.present? ? strategies.last.number+1 : 1
  end
end

