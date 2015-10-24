class MyFile
  attr_accessor :path
  attr_writer :data

  def initialize(attributes = {})
    @path = attributes[:path]
    @data = attributes[:data]
  end

  def data
    return @data if @data
    File.read(@path) if exist?
  end

  def write
    return nil unless @path
    FileUtils.mkdir_p File.dirname(@path)
    File.write(@path, @data)
  end

  def exist?
    return false unless @path
    File.exist?(@path)
  end
end

