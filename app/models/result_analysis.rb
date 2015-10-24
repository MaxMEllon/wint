class ResultAnalysis
  public_constant

  HAND = 10 # 役の数

  private_constant

  VERSION = 1.0

  module DirName
    MAIN = 'result'
  end

  module FileName
    MAIN = 'result.json'
    BASE = 'Result.txt'
  end

  public

  def initialize(attributes = {})
    @path = attributes[:path] + '/' + DirName::MAIN
    base_file.data = attributes[:data]
    @ver = VERSION
  end

  def save
    save! rescue false
  end

  def save!
    base_file.write
    json = { ver: @ver, base_path: base_file.path, score: score, table_amount: table_amount }
    main_json.data = ModelHelper.encode_json(json)
    main_json.write
    true
  end

  def latest?
    @ver >= VERSION
  end

  def to_csv
    [score].join(',')
  end

  def main_data
    @main_data ||= ModelHelper.decode_json main_json.data
  rescue
    @main_data = {}
  end

  def main_json
    @main_json ||= MyFile.new(path: "#{@path}/#{FileName::MAIN}")
  end

  def base_file
    @base_file ||= MyFile.new(path: "#{@path}/#{FileName::BASE}")
  end

  def score
    return main_data[:score] if main_data[:score]
    @score ||= base_file.data.split.last.to_f
  end

  def table_amount
    return main_data[:table_amount] if main_data[:table_amount]
    return @table_amount if @table_amount

    @table_amount = {}
    table[1..-3].each.with_index(0) do |row, i|
      @table_amount["P#{i}"] = row.last.to_i
    end
    @table_amount = @table_amount.symbolize_keys
  end

  def table
    return @table if @table
    @table = base_file.data.split(/\r\n|\n/)
    @table.map! { |line| line.gsub(/\||-|\+/, '').split }
    @table = @table.delete_if { |line| line.empty? || line.first == '平均得点' }
  end

  public_class_method

  def self.to_csv_header
    %w(得点).join(',')
  end

  def self.create(attributes = {})
    ResultAnalysis.new(attributes).tap(&:save!)
  end
end

