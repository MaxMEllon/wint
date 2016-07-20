# == Schema Information
#
# Table name: leagues
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  start_at    :datetime         default(2014-10-24 15:06:30 +0000), not null
#  end_at      :datetime         default(2014-10-24 15:06:30 +0000), not null
#  limit_score :float            default(0.0), not null
#  is_analy    :boolean          default(FALSE), not null
#  data_dir    :string(255)      default(""), not null
#  rule_file   :string(255)      default(""), not null
#  is_active   :boolean          default(TRUE), not null
#  created_at  :datetime
#  updated_at  :datetime
#

class League < ActiveRecord::Base
  has_many :players, dependent: :destroy

  validates_presence_of :name, :start_at, :end_at, :limit_score, :data_dir, :rule_file

  Scope.active(self)

  BASE_PATH = "#{Rails.root}/public/data"

  def rank(strategy)
    Strategy::RANK.each do |range, rank|
      return rank if range.include?(self.achievement(strategy))
    end
  end

  def achievement(strategy)
    (strategy.score / self.limit_score) * 100
  end

  def players_ranking
    self.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
  end

  def open?
    now = Time.new
    self.start_at <= now && now < self.end_at
  end

  def self.select_format
    self.all.map {|l| [l.name, l.id]}
  end

  def rule(symbol = nil)
    return nil if self.rule_file.blank?
    rules = ModelHelper.decode_json(File.read(self.rule_file))
    symbol.present? ? rules[symbol] : rules
  end

  def format_rule
    rules = rule
    "#{"%02d" % rules[:change]}-#{"%02d" % rules[:take]}-#{rules[:try]}"
  end

  def mkdir
    ("#{BASE_PATH}/%03d" % self.id).tap do |path|
      Dir::mkdir(path)
      Dir::mkdir("#{path}/rule")
      Dir::mkdir("#{path}/source")
    end
  end

  def set_rule(params)
    (self.data_dir + "/rule/rule.json").tap do |path|
      File.open(path, "w") {|f| f.puts ModelHelper.encode_json params}
    end
  end
end

