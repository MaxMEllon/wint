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

  validates_presence_of :name, :start_at, :end_at, :limit_score, :data_dir, :change, :take, :try

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

  def format_rule
    "#{"%02d" % change}-#{"%02d" % take}-#{try}"
  end

  def mkdir
    ("#{BASE_PATH}/%03d" % self.id).tap do |path|
      Dir::mkdir(path)
    end
  end
end

