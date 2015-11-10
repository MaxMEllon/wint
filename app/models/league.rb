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

  public

  def rule
    @rule ||= Rule.load(data_dir)
  end

  def rule_path
    rule.path
  end

  def source_path
    data_dir + '/source'
  end

  def rank(strategy)
    Submit::RANK.each do |range, rank|
      return rank if range.include?(achievement(strategy))
    end
  end

  def achievement(strategy)
    (strategy.score / limit_score) * 100
  end

  def open?
    now = Time.new
    start_at <= now && now < end_at
  end

  # @Override
  def update(attributes = {})
    rule.update(
      change: attributes.delete(:change),
      take: attributes.delete(:take),
      try: attributes.delete(:try),
      card: attributes.delete(:card),
      exec: attributes.delete(:exec),
      header: attributes.delete(:header),
      stock: attributes.delete(:stock)
    )
    super(attributes)
  end

  def ranking
    players = Player.includes(:submits, :best, :user).where(league_id: id)
    players.select(&:best).sort { |a, b| b.best.score <=> a.best.score }
  end

  public_class_method

  # @Override
  def self.create(attributes = {})
    attributes[:data_dir] = format("#{ModelHelper.data_root}/%03d", last_id)
    create_dirs(attributes[:data_dir])
    rule = Rule.create(
      path: attributes[:data_dir],
      change: attributes.delete(:change),
      take: attributes.delete(:take),
      try: attributes.delete(:try),
      card: attributes.delete(:card),
      exec: attributes.delete(:exec),
      header: attributes.delete(:header),
      stock: attributes.delete(:stock)
    )
    attributes[:rule_file] = rule.path
    super(attributes)
  end

  def self.select_format
    all.map { |l| [l.name, l.id] }
  end

  private_class_method

  def self.create_dirs(path)
    FileUtils.mkdir(path)
    FileUtils.mkdir(path + '/source')
  end

  def self.last_id
    League.count == 0 ? 1 : League.last.id + 1
  end
end

