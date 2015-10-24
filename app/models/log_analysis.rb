class LogAnalysis
  private_constant

  VERSION = 1.0

  module DirName
    MAIN = 'log'
  end

  module FileName
    MAIN = 'log.json'
    BASE = 'Game.log'
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
    json = { ver: @ver, base_path: base_file.path }
    main_json.data = ModelHelper.encode_json(json)
    main_json.write
    true
  end

  def latest?
    @ver >= VERSION
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

  def to_csv
    [].join(",")
  end

  public_class_method

  def self.to_csv_header
    %w().join(",")
  end

  def self.create(attributes = {})
    LogAnalysis.new(attributes).tap(&:save!)
  end
end

