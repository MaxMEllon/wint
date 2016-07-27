class ResultAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/result'
    @base_file_path = @path + '/Result.txt'
  end

  def result_table
    File.read(@base_file_path).split(/\r\n|\n/)
      .map { |line| line.gsub(/\||-|\+/, '').split }
      .delete_if { |line| line.empty? || line.first == '平均得点' }
  end

  def analyze_score
    File.read(@base_file_path).split.last.to_f
  end

  public_class_method

  def self.create(analysis_path, content)
    path = analysis_path + '/result'
    Dir.mkdir(path)
    File.write(path + '/Result.txt', content)
    new(analysis_path)
  end
end

