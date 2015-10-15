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
    @change = attributes[:change]
    @take = attributes[:take]
    @try = attributes[:try]
    @card_data = attributes[:card]
    @exec_data = attributes[:exec]
    @header_data = attributes[:header]
    @stock_data = attributes[:stock]
  end

  def save
    FileUtils.mkdir(@path) unless File.exist?(@path)
    reg = { change: @change, take: @take, try: @try }
    json_data = ModelHelper.encode_json reg
    write_file FileName::JSON, json_data
    write_file FileName::CARD, @card_data
    write_file FileName::EXEC, @exec_data
    write_file FileName::HEADER, @header_data
    write_file FileName::STOCK, @stock_data
    true
  rescue
    false
  end

  def update(attributes = {})
    @card_data = attributes[:card]
    @exec_data = attributes[:exec]
    @header_data = attributes[:header]
    @stock_data = attributes[:stock]
    @change = attributes[:change]
    @take = attributes[:take]
    @try = attributes[:try]
    save
  end

  def text
    [format('%02d', @change), format('%02d', @take), @try].join('-')
  end

  def regulation
    reg = ModelHelper.decode_json File.read("#{@path}/#{FileName::JSON}")
    reg.map { |k, v| [k, v.to_i] }.to_h
  rescue
    { change: 0, take: 0, try: 0 }
  end

  private

  def write_file(filename, data)
    return if data.nil?
    File.write "#{@path}/#{filename}", data
  end

  public_class_method

  def self.create(attributes = {})
    Rule.new(attributes).tap(&:save)
  end

  def self.load(attributes = {})
    Rule.new(attributes).tap do |rule|
      reg = rule.regulation
      rule.change = reg[:change]
      rule.take = reg[:take]
      rule.try = reg[:try]
    end
  end
end

