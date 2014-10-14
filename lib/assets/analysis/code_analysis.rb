
class CodeAnalysis
  VERSION = 1.0

  def initialize(cpath)
    data = ModelHelper.decode_json(File.read(cpath))
    @ver = data[:ver]
  end

  def self.create(data_dir)
    path = data_dir + "/code"
    Dir::mkdir(path)
    (path + "/code.json").tap do |cpath|
      File.open(cpath, "w") do |f|
        f.puts ModelHelper.encode_json(self.params(path))
      end
    end
  end

  private
  def self.params(path)
    {
      ver: VERSION
    }
  end
end

