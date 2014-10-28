class League < ActiveRecord::Base
  has_many :players, dependent: :destroy

  validates_presence_of :name, :start_at, :end_at, :limit_score, :data_dir, :rule_file

  Scope.active(self)

  def rank(strategy)
    Strategy::RANK.each do |range, rank|
      return rank if range.include?(self.achievement(strategy))
    end
  end

  def achievement(strategy)
    (strategy.score / self.limit_score) * 100
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
    "#{"%02d" % rules[:take]}-#{"%02d" % rules[:change]}-#{rules[:try]}"
  end

  def mkdir
    ("#{Rails.root}/public/data/%03d" % self.id).tap do |path|
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

