require "analysis/result_analysis"
require "analysis/code_analysis"
require "analysis/log_analysis"

class AnalysisManager
  attr_reader :result, :code, :log

  def initialize(path)
    @data = ModelHelper.decode_json(File.read(path))
    @result = ResultAnalysis.new(@data[:rpath])
    @code = CodeAnalysis.new(@data[:cpath])
    @log = LogAnalysis.new(@data[:lpath])
  end

  def update
    @result.update
    @code.update
    @log.update
    save
  end

  def save
    File.open(@data[:rpath], "w") {|f| f.puts ModelHelper.encode_json(@result)}
    File.open(@data[:cpath], "w") {|f| f.puts ModelHelper.encode_json(@code)}
    File.open(@data[:lpath], "w") {|f| f.puts ModelHelper.encode_json(@log)}
  end

  def self.create(data_dir)
    path = data_dir + "/analy"
    Dir::mkdir(path)
    rpath = ResultAnalysis.create(path + "/result")
    cpath = CodeAnalysis.create(path + "/code", data_dir + "/PokerOpe.c")
    lpath = LogAnalysis.create(path + "/log")
    (path + "/analy.json").tap do |analy_file|
      File.open(analy_file, "w") do |f|
        f.puts ModelHelper.encode_json({rpath: rpath, cpath: cpath, lpath: lpath})
      end
    end
  end
end

