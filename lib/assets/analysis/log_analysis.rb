
class LogAnalysis
  VERSION = 1.0

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base = data[:base]
  end

  def update
    return unless @ver < VERSION
    @ver = VERSION
  end

  def self.create(data_dir)
    Dir::mkdir(data_dir)
    `mv #{Rails.root}/tmp/log/_tmp/Game.log #{data_dir}`
    (data_dir + "/log.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base: "#{data_dir}/Game.log"})
      end
    end
  end
end

