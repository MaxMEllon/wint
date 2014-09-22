class League < ActiveRecord::Base
  has_many :players, dependent: :destroy

  validates_presence_of :name, :start_at, :end_at, :limit_score, :src_dir, :rule_file

  def self.select_format
    self.all.map {|l| [l.name, l.id]}
  end

  def rule(symbol = nil)
    return nil if self.rule_file.blank?
    rules = ModelHelper.decode_json(File.read(self.rule_file))
    return rules[symbol] if symbol.present?
    rules
  end

  def format_rule
    rules = rule
    "%02d-%02d-#{rules["try"]}" % [rules["take"], rules["change"]]
  end

  def self.mkdir
    path = "#{Rails.root}/public/data/%03d" % get_id
    Dir::mkdir(path)
    Dir::mkdir("#{path}/rule")
    Dir::mkdir("#{path}/source")
  end

  def self.rmdir
    path = "#{Rails.root}/public/data/%03d" % get_id
    `rm -rf #{path}` # いつか直すかも
  end

  def set_src(params)
    path = "#{Rails.root}/public/data/%03d/rule" % League.get_id
    filenames = {stock: "Stock.ini", header: "Poker.h", exec: "PokerExec.c", card: "CardLib.c"}
    begin
      filenames.each do |key, value|
        file = path + "/" + value
        File.open(file, "w") {|f| f.puts params[key].read.force_encoding("utf-8")}
        `nkf --overwrite -w #{file}` # いつか直すかも
      end
    rescue
      return nil
    end
    path
  end

  def set_rule(params)
    return nil if params[:take].blank? || params[:change].blank? || params[:try].blank?

    path = "#{Rails.root}/public/data/%03d/rule/rule.json" % League.get_id
    begin
      File.open(path, "w") {|f| f.puts ModelHelper.encode_json params}
    rescue
      return nil
    end
    path
  end

  private
  def self.get_id
    id = 1
    id = League.last.id+1 if League.last.present?
    id
  end
end

