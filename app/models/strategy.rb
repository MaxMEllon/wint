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

require 'analysis/result_analysis.rb'
require 'analysis/log_analysis.rb'
require 'analysis/code_analysis.rb'
require 'analysis/adlint_analysis.rb'

class Strategy < ActiveRecord::Base
  belongs_to :submit
  has_one :player, through: :submit
  has_one :league, through: :player

  scope :score_by, -> { order('score DESC') }
  scope :number_by, -> { order('number') }

  after_create :after_create

  RANK = {
    0...30 => 'X',
    30...35 => 'C',
    35...40 => 'B',
    40...45 => 'A',
    45...50 => 'S',
    50...75 => 'SS',
    75..100 => 'SSS'
  }

  def after_create
    Dir.mkdir(submit.analysis_path)

    # code
    content = File.read(submit.src_file)
    CodeAnalysis.create(submit.analysis_path, content)

    # adlint
    content = File.read(submit.src_file)
    AdlintAnalysis.create(submit.analysis_path, content)

    # result
    content = File.read("#{Rails.root}/tmp/log/_tmp#{submit.id}/Result.txt")
    ResultAnalysis.create(submit.analysis_path, content)

    # log
    content = File.read("#{Rails.root}/tmp/log/_tmp#{submit.id}/Game.log")
    LogAnalysis.create(submit.analysis_path, content)

    update(
      score: result_analysis.analyze_score,
      abc_size: adlint_analysis.analyze_abc_size,
      statement: adlint_analysis.analyze_statement,
      func_num: adlint_analysis.analyze_func_num
    )
  end

  def result_analysis
    @result_analysis ||= ResultAnalysis.new(submit.analysis_path)
  end

  def log_analysis
    @log_analysis ||= LogAnalysis.new(submit.analysis_path)
  end

  def code_analysis
    @code_analysis ||= CodeAnalysis.new(submit.analysis_path)
  end

  def adlint_analysis
    @adlint_analysis ||= AdlintAnalysis.new(submit.analysis_path)
  end

  def get_result_table
    result_analysis.result_table
  end

  def analysis_update
  end

  def best?
    strategies = submit.player.strategies.score_by
    return true if strategies.blank? || score >= strategies.first.score
    false
  end

  def plot_abc_size
    { name: player.user.snum, x: score, y: abc_size }
  end

  def to_csv
    [score, abc_size, statement, func_num].join(',')
  end

  private

  def self.get_number(submit)
    strategies = submit.player.strategies.number_by
    strategies.present? ? strategies.last.number + 1 : 1
  end

  public_class_method

  def self.to_csv_header
    %w(得点 ABCサイズ ステート数 関数の定義数).join(',')
  end

  # override
  def self.create(submit)
    super(submit_id: submit.id, number: Strategy.get_number(submit))
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
end

