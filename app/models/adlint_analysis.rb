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
    # base_file.data = attributes[:data]
    @ver = VERSION
  end

  def save
    save!
  rescue
    false
  end

  def save!
    base_file.data.gsub!(/#include/, '// #include')
    base_file.write
    json = { ver: @ver, base_path: base_file.path, line: line,
             static_path: static_path,
             func_ref: {
               strategy: func_ref[:strategy],
               max: func_ref[:max],
               average: func_ref[:average] },
             func_num: func_num }
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



  def functions
    return @functions if @functions
    @functions = []

    unless base_file.exist?
      base_file.data.gsub!(/#include/, '// #include')
      base_file.write
    end

    `cd #{@path} && adlintize -o analysis && cd #{@path}/analysis && make verbose-all`
    data = File.read("#{@path}/analysis/PokerOpe.c.met.csv").split(/\n/)[1..-1]
    result = split_keyword(data, 'FN_PATH').zip(split_keyword(data, 'FN_CYCM'))
    result.map! {|r| r.flatten}
    result.each do |r|
      @functions << Function.new(r)
    end
    @functions
  end

  def split_keyword(data, keyword)
    result = []
    loop do
      i = data.index { |d| d =~ /#{keyword}/ }
      break if i.nil?
      result << data.slice!(0, i + 1)
    end
    result
  end

  def static_path
    return main_data[:static_path] if main_data[:static_path]
    @static_path ||= functions.map { |f| f.records[:path] }.inject(:+)
  end

  def func_ref
    return main_data[:func_ref] if main_data[:func_ref]
    csubs = functions.map { |f| f.records[:csub] }
    @func_ref ||= {
      strategy: functions.find { |f| f.name == 'strategy' }.records[:csub],
      max: csubs.max,
      average: csubs.inject(:+) / functions.count
    }
  end

  def line
    return main_data[:line] if main_data[:line]
    @line ||= functions.map { |f| f.records[:line] }.inject(:+)
  end

  def func_num
    return main_data[:func_num] if main_data[:func_num]
    @func_num ||= functions.count
  end

  def to_csv
    [line, static_path, func_ref[:strategy],
     func_ref[:max], func_ref[:average], func_num].join(',')
  end

  def self.to_csv_header
    %w(行数 推定静的パス数 strategy関数からの呼出回数 最多呼出回数 平均呼出回数 関数の定義数).join(',')
  end

  def self.create(attributes = {})
    CodeAnalysis.new(attributes).tap(&:save!)
  end
end

