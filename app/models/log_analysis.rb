
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

  def to_csv
    [].join(",")
  end

  def self.to_csv_header
    %w().join(",")
  end

  def self.create(data_dir, game_log)
    Dir::mkdir(data_dir)
    File.write(data_dir + '/Game.log', game_log)
    (data_dir + "/log.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base_path: "#{data_dir}/Game.log"})
      end
    end
  end
end

