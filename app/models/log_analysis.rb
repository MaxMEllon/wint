
class LogAnalysis
  VERSION = 1.0

  def initialize(attributes = {})
    data = ModelHelper.decode_json(File.read(attributes[:path]))
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

  def self.create(data_dir, log)
    path = data_dir + '/log'
    log.path = path + '/Game.log'
    log.write
    data = ModelHelper.encode_json({ver: 0.0, base_path: log.path})
    json = MyFile.new(path: path + '/log.json',data: data)
    json.write
    json.path
  end
end

