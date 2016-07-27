class LogAnalysis
  def initialize(analysis_path)
    @path = analysis_path + '/log'
    @base_file_path = @path + '/Game.log'
  end

  public_class_method

  def self.create(analysis_path, content)
    path = analysis_path + '/log'
    Dir.mkdir(path)
    File.write(path + '/Game.log', content)
    new(analysis_path)
  end
end

