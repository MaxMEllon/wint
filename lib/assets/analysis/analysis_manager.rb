require "analysis/result_analysis"
require "analysis/code_analysis"
require "analysis/log_analysis"

class AnalysisManager

  # Strategy
  def initialize(data_dir)
    dirs = ModelHelper.decode_json(File.read(data_dir + "/analy/analy.json"))
    result = ResultAnalysis.new(dirs[:rpath])
    code = CodeAnalysis.new(dirs[:cpath])
    log = LogAnalysis.new(dirs[:lpath])
    @analy = {result: result, code: code, log: log}
  end

  # update

  def get_score
    @analy[:result].score
  end

  def self.create(data_dir)
    path = data_dir + "/analy"
    Dir::mkdir(path)
    rpath = ResultAnalysis.create(path)
    cpath = CodeAnalysis.create(path)
    lpath = LogAnalysis.create(path)
    (path + "/analy.json").tap do |analy_file|
      File.open(analy_file, "w") do |f|
        f.puts ModelHelper.encode_json({rpath: rpath, cpath: cpath, lpath: lpath})
      end
    end
  end
end

