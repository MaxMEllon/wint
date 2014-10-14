
class LogAnalysis
  VERSION = 1.0

  def initialize(lpath)
    data = ModelHelper.decode_json(File.read(lpath))
    @ver = data[:ver]
    @log_file = data[:log]
  end

  def self.create(data_dir)
    path = data_dir + "/log"
    Dir::mkdir(path)
    `mv #{Rails.root}/tmp/log/_tmp/Game.log #{path}`
    (path + "/log.json").tap do |lpath|
      File.open(lpath, "w") do |f|
        f.puts ModelHelper.encode_json(self.params(path))
      end
    end
  end

  private
  def self.params(path)
    {
      ver: VERSION,
      log: self.log_file(path)
    }
  end

  def self.log_file(path)
    path + "/Game.log"
  end
end

