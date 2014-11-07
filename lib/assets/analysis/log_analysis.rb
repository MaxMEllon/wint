
class LogAnalysis
  VERSION = 1.0

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base_path = data[:base_path]
  end

  def latest?
    @ver >= VERSION
  end

  def update
    return if self.latest?
    @ver = VERSION
  end

  def self.create(data_dir, submit_id)
    Dir::mkdir(data_dir)
    `mv #{Rails.root}/tmp/log/_tmp#{submit_id}/Game.log #{data_dir}`
    (data_dir + "/log.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base_path: "#{data_dir}/Game.log"})
      end
    end
  end
end

