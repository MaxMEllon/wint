class AnalysisManager
  attr_reader :path

  def initialize(attributes = {})
    @path = attributes[:path]
    result.base_file.data = attributes[:result]
    code.base_file.data = attributes[:code]
    adlint.base_file.data = attributes[:adlint]
    log.base_file.data = attributes[:log]
  end

  def result
    @result ||= ResultAnalysis.new(path: @path)
  end

  def code
    @code ||= CodeAnalysis.new(path: @path)
  end

  def adlint
    @adlint ||= AdlintAnalysis.new(path: @path)
  end

  def log
    @log ||= LogAnalysis.new(path: @path)
  end

  def self.load(path)
    AnalysisManager.new(path: path)
  end

  def update
    save
  end

  def save
    save!
  rescue
    false
  end

  def save!
    result.save! && code.save! && adlint.save! && log.save!
  end

  def plot_size
    { x: result.score, y: code.size }
  end

  def plot_syntax
    { x: result.score, y: adlint.static_path }
  end

  def plot_fun
    { x: result.score, y: adlint.func_num }
  end

  def plot_gzip
    { x: result.score, y: (1 - (code.gzip_size / code.size.to_f)) * 100 }
  end

  def to_csv
    [result.to_csv, code.to_csv, adlint.to_csv].join(',')
  end

  def self.to_csv_header
    [
      ResultAnalysis.to_csv_header,
      CodeAnalysis.to_csv_header,
      AdlintAnalysis.to_csv_header
    ].join(',')
  end

  def self.create(attributes = {})
    AnalysisManager.new(attributes).tap(&:save!)
  end
end

