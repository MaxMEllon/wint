class AnalysisManager
  attr_reader :result, :code, :log

  def initialize(path)
    return nil if path.blank?
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

  def plot_size
    {x: @result.score, y: @code.size}
  end

  def plot_syntax
    {x: @result.score, y: @code.count[:loop] + @code.count[:if]}
  end

  def plot_fun
    {x: @result.score, y: @code.func_num}
  end

  def plot_gzip
    {x: @result.score, y: (1-(@code.gzip_size / @code.size.to_f))*100}
  end

  def to_csv
    # [@result.to_csv, @code.to_csv, @log.to_csv].join(",")
    [@result.to_csv, @code.to_csv].join(",")
  end

  def self.to_csv_header
    # [ResultAnalysis.to_csv_header, CodeAnalysis.to_csv_header, LogAnalysis.to_csv_header].join(",")
    [ResultAnalysis.to_csv_header, CodeAnalysis.to_csv_header].join(",")
  end

  def self.create(attributes = {})
    path = attributes[:path] + "/analy"
    rpath = ResultAnalysis.create(path + "/result", attributes[:result].data)
    cpath = CodeAnalysis.create(path + "/code", attributes[:code].data)
    lpath = LogAnalysis.create(path + "/log", attributes[:log].data)
    (path + "/analy.json").tap do |analy_file|
      File.open(analy_file, "w") do |f|
        f.puts ModelHelper.encode_json({rpath: rpath, cpath: cpath, lpath: lpath})
      end
    end
  end
end

