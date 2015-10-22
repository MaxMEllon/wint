class MyFile
  def initialize(attributes = {})
    @path = attributes[:path]
    @data = attributes[:data]
  end

  def write
    File.write(@path) { |f| f.puts @data }
  end

  def data
    @data ||= exist? && File.read(@path)
  end

  def exist?
    return false unless @path
    File.exist?(@path)
  end
end

