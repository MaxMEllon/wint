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

  after_create do
    path = format("#{BASE_PATH}/%03d", id)
    Dir.mkdir(path)
    update(data_dir: path)
  end

  def rank(strategy)
    Strategy::RANK.each do |range, rank|
      return rank if range.include?(achievement(strategy))
    end
  end

  def achievement(strategy)
    (strategy.score / limit_score) * 100
  end

  def players_ranking
    players.select(&:best).sort { |a, b| b.best.strategy.score <=> a.best.strategy.score }
  end

  def open?
    now = Time.new
    start_at <= now && now < end_at
  end

  def format_rule
    format_change = format('%02d', change)
    format_take = format('%02d', take)
    "#{format_change}-#{format_take}-#{try}"
  end

  private_class_method

  def self.select_format
    all.map { |l| [l.name, l.id] }
  end

  def self.create(attributes)
    attributes[:data_dir] = 'dummy'
    super(attributes)
  end
end

