class MyFile
  attr_accessor :path, :data

  def initialize(attributes = {})
    @path = attributes[:path]
    @data = attributes[:data]
  end

  def data
    @data ||= exist? && File.read(@path)
  end

  def write
    return nil unless @path
    File.write(@path, @data)
  rescue Errno::ENOENT
    FileUtils.mkdir_p File.dirname(@path)
    retry
  end

  def exist?
    return false unless @path
    File.exist?(@path)
  end
end

