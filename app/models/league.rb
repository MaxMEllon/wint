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

  # def self.create(attributes)
  #   attributes[:data_dir] = format("#{ModelHelper.data_root}/%03d", last_id) if attributes[:data_dir].nil?
  #   create_dirs(attributes[:data_dir])
  #   `unzip #{attributes[:rule_files]} -d #{attributes[:data_dir]}/rule` # 後で直す
  #   `mv #{attributes[:data_dir]}/rule/*/* #{attributes[:data_dir]}/rule` # 後で直す、必ずだ
  #   attributes[:rule_file] = attributes[:data_dir] + '/rule/rule.json' if attributes[:rule_file].nil?
  #   attributes.delete(:rule_files)
  #   super(attributes)
  # end

  def self.create(attributes)
    attributes[:data_dir] = format("#{ModelHelper.data_root}/%03d", last_id)
    create_dirs(attributes[:data_dir])
    File.open(attributes[:data_dir] + '/rule/Stock.ini', "w") { |f| f.puts attributes.delete(:stock) }
    File.open(attributes[:data_dir] + '/rule/Poker.h', "w") { |f| f.puts attributes.delete(:header) }
    File.open(attributes[:data_dir] + '/rule/PokerExec.c', "w") { |f| f.puts attributes.delete(:exec) }
    File.open(attributes[:data_dir] + '/rule/CardLib.c', "w") { |f| f.puts attributes.delete(:card) }
    attributes[:rule_file] = (attributes[:data_dir] + "/rule/rule.json").tap do |path|
      File.open(path, "w") { |f| f.puts attributes.delete(:rule_json) }
    end

    super(attributes)
  end

  def self.create_dirs(path)
    FileUtils.mkdir(path)
    FileUtils.mkdir(path + '/rule')
    FileUtils.mkdir(path + '/source')
  end

  def rule_path
    data_dir + '/rule'
  end

  def source_path
    data_dir + '/source'
  end

  def self.last_id
    League.count == 0 ? 1 : League.last.id + 1
  end

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
    ("#{ModelHelper.data_root}/%03d" % self.id).tap do |path|
      Dir::mkdir(path)
      Dir::mkdir("#{path}/rule")
      Dir::mkdir("#{path}/source")
    end
  end

  def set_data(params)
    path = self.data_dir + "/rule"
    filenames = {stock: "Stock.ini", header: "Poker.h", exec: "PokerExec.c", card: "CardLib.c"}
    params.each do |key, value|
      file = path + "/" + filenames[key.to_sym]
      File.open(file, "w") do |f|
        f.puts params[key].read.force_encoding("utf-8")
      end
      `nkf --overwrite -w #{file}` # いつか直すかも
    end
  end

  def set_rule(params)
    (self.data_dir + "/rule/rule.json").tap do |path|
      File.open(path, "w") {|f| f.puts ModelHelper.encode_json params}
    end
  end
end

