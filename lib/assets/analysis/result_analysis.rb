
class ResultAnalysis
  attr_reader :score

  VERSION = 1.0

  def initialize(rpath)
    data = ModelHelper.decode_json(File.read(rpath))
    @ver = data[:ver]
    @result_path = data[:result]
    @score = data[:score]
  end

  def self.create(data_dir)
    path = data_dir + "/result"
    Dir::mkdir(path)
    `mv #{Rails.root}/tmp/log/_tmp/Result.txt #{path}`
    (path + "/result.json").tap do |rpath|
      File.open(rpath, "w") do |f|
        f.puts ModelHelper.encode_json(self.params(path))
      end
    end
  end

  private
  def self.params(path)
    {
      ver: VERSION,
      result: self.result_file(path),
      score: self.get_score(path)
    }
  end

  def self.get_score(path)
    File.read(result_file(path)).split.last
  end

  def self.result_file(path)
    path + "/Result.txt"
  end
end

