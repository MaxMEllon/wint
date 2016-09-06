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
  has_many :strategies, through: :players

  validates_presence_of :name, :start_at, :end_at, :limit_score, :data_dir, :change, :take, :try

  Scope.active(self)

  RULE_PATH = "#{Rails.root}/lib/poker"

  after_create :after_create

  def after_create
    base_path = "data/#{Rails.env}"
    Dir.mkdir(base_path) unless File.exist?(base_path)

    path = format("#{base_path}/%03d", id)
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

  def best_strategies
    players_ranking.map { |player| player.best.strategy }
  end

  def participants
    players.where(role: Player::ROLE_PARTICIPANT)
  end

  def auditors
    players.where(role: Player::ROLE_AUDITOR)
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

  def compile_command(src_file, exec_file)
    type = format('%02d-%02d', take, change)
    files = "#{src_file} #{RULE_PATH}/PokerExec.c #{RULE_PATH}/CardLib.c"
    options = "-DTYPE=#{type} -DTAKE=#{take} -DCHNG=#{change}"
    "gcc -O2 -I#{RULE_PATH} #{files} #{options} -o#{exec_file}"
  end

  def execute_command(exec_file, submit_id)
    "cd #{Rails.root}/tmp && #{exec_file} _tmp#{submit_id} #{try} #{RULE_PATH}/Stock.ini 0"
  end

  def submissions_count_per_day
    sum = start_at
    per_day = {}
    while sum < end_at
      per_day[sum] = strategies.where(created_at: sum..(sum + 1.days)).count
      sum += 1.days
    end
    per_day
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

