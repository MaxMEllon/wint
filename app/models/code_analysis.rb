class CodeAnalysis
  VERSION = 1.0

  module DirName
    MAIN = 'code'
  end

  module FileName
    MAIN = 'code.json'
    BASE = 'PokerOpe.c'
  end

  def initialize(attributes = {})
    @path = attributes[:path] + '/' + DirName::MAIN
    base_file.data = attributes[:data]
    @ver = VERSION
  end

  def save
    save!
  rescue
    false
  end

  def save!
    base_file.write
    json = { ver: @ver, base_path: base_file.path, size: size, gzip_size: gzip_size }
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

  def comcut
    return @comcut if @comcut
    tmp = MyFile.new(
      path: "#{@path}/comcut_tmp.c",
      data: base_file.data.gsub('#include', 'hogefoobar')
    )
    tmp.write
    comcut_data = `gcc -E -P #{tmp.path}`.split(/\r\n|\n/)
    data = comcut_data.reject { |line| line =~ /hogefoobar/ }.join('\n')
    path = "#{@path}/comcut.c"
    @comcut = MyFile.new(path: path, data: data).tap(&:write)
  end

  def gzip
    return @gzip if @gzip
    path = "#{@path}/comcut.gz"
    data = `gzip -c -9 #{comcut.path}`
    @gzip = MyFile.new(path: path, data: data).tap(&:write)
  end

  def size
    return main_data[:size] if main_data[:size]
    @size ||= File.stat(comcut.path).size
  end

  def gzip_size
    @gzip_size ||= File.stat(gzip.path).size
  end

  def to_csv
    [size, gzip_size].join(',')
  end

  def self.to_csv_header
    %w(ファイルサイズ 圧縮ファイルサイズ).join(',')
  end

  def self.create(attributes = {})
    CodeAnalysis.new(attributes).tap(&:save!)
  end
end

