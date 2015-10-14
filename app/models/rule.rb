class Rule
  include ActiveModel::Model

  attr_accessor :path, :change, :take, :try

  private_constant

  module FileName
    CARD = 'CardLib.c'
    EXEC = 'PokerExec.c'
    HEADER = 'Poker.h'
    STOCK = 'Stock.ini'
    JSON = 'rule.json'
  end

  DIR_NAME = 'rule'

  public

  def initialize(attributes = {})
    @path = attributes[:path] + '/' + DIR_NAME
    rules = read_rules
    @change = rules[:change]
    @take = rules[:take]
    @try = rules[:try]
  end

  def text
    [format('%02d', @change), format('%02d', @take), @try].join('-')
  end

  private

  def read_rules
    rules = ModelHelper.decode_json File.read(@path + '/' + FileName::JSON)
    rules.map { |k, v| [k, v.to_i] }.to_h
  rescue
    { change: 0, take: 0, try: 0 }
  end

  private_class_method

  def self.create(attributes = {})
    path = attributes[:path] + '/' + DIR_NAME
    FileUtils.mkdir(path)
    File.write("#{path}/#{FileName::CARD}", attributes[:card])
    File.write("#{path}/#{FileName::EXEC}", attributes[:exec])
    File.write("#{path}/#{FileName::HEADER}", attributes[:header])
    File.write("#{path}/#{FileName::STOCK}", attributes[:stock])
    File.write("#{path}/#{FileName::JSON}", attributes[:rule_json])
  end
end

