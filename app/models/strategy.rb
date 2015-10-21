# == Schema Information
#
# Table name: strategies
#
#  id         :integer          not null, primary key
#  submit_id  :integer          not null
#  score      :float            default(0.0), not null
#  number     :integer          not null
#  analy_file :string(255)      default(""), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

class Strategy < ActiveRecord::Base
  belongs_to :submit
  has_one :player, through: :submit
  has_one :league, through: :player

  scope :score_by, -> { order('score DESC') }
  scope :number_by, -> { order('number') }

  RANK = {
    0...30 => 'X',
    30...35 => 'C',
    35...40 => 'B',
    40...45 => 'A',
    45...50 => 'S',
    50...75 => 'SS',
    75..100 => 'SSS'
  }

  # override
  def self.create(submit, game_log, result)
    AnalysisManager.create(submit.data_dir, game_log, result)
    analy = AnalysisManager.new(submit.analysis_file)
    analy.update
    super(submit_id: submit.id, analy_file: submit.analysis_file, score: analy.result.score, number: Strategy.get_number(submit))
  end

  def self.hand_text
    {
      P0: 'ノーペア',
      P1: 'ワンペア',
      P2: 'ツーペア',
      P3: 'スリーカード',
      P4: 'ストレート',
      P5: 'フラッシュ',
      P6: 'フルハウス',
      P7: 'フォーカード',
      P8: 'ストレートフラッシュ',
      P9: 'ロイヤルストレート'
    }
  end

  def analysis_update
    AnalysisManager.new(analy_file).update
  end

  def best?
    strategies = submit.player.strategies.score_by
    return true if strategies.blank? || score >= strategies.first.score
    false
  end

  private_class_method

  def self.get_number(submit)
    strategies = submit.player.strategies.number_by
    strategies.present? ? strategies.last.number + 1 : 1
  end
end

