class AdlintAnalysis
  VERSION = 1.0

  module DirName
    MAIN = 'adlint'
  end

  module FileName
    MAIN = 'adlint.json'
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
    json = { ver: @ver, base_path: base_file.path, line: line,
             count_if: count[:if], count_loop: count[:loop],
             func_ref_strategy: func_ref[:strategy], func_ref_max: func_ref[:max],
             func_ref_average: func_ref[:average], func_num: func_num }
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

  def cflow
    return @cflow if @cflow
    path = comcut.path.sub(/comcut.c/, 'cflow.dat')
    data = `cflow --omit-symbol-names --omit-arguments #{comcut.path}`
    @cflow = MyFile.new(path: path, data: data)
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

  def function
    @function ||= FunctionAnalysis.new(cflow)
  end

  def syntax
    @syntax ||= SyntaxAnalysis.new(comcut)
  end

  def count
    @count ||= syntax.count_all_word
  end

  def func_ref
    @func_ref ||= function.amount_func_ref
  end

  def line
    return main_data[:line] if main_data[:line]
    @line ||= comcut.data.split(/\r\n|\n/).size
  end

  def func_num
    return main_data[:func_num] if main_data[:func_num]
    # 一番上の行は要らない。strategyはカウントしない
    @func_num ||= File.read(function.func_ref_path).split(/\r\n|\n/).size - 2
  end

  def to_csv
    [line, count[:if], count[:loop], func_ref[:strategy],
     func_ref[:max], func_ref[:average], func_num].join(',')
  end

  def self.to_csv_header
    %w(行数 ifの条件の数 loopの数 strategy関数からの呼出回数 最多呼出回数 平均呼出回数 関数の定義数).join(',')
  end

  def self.create(attributes = {})
    CodeAnalysis.new(attributes).tap(&:save!)
  end
end

