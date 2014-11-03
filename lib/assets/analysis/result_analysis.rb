
class ResultAnalysis
  attr_reader :score

  VERSION = 1.0

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base_path = data[:base_path]
    @score = data[:score].to_f
  end

  def latest?
    @ver >= VERSION
  end

  def update
    return if self.latest?
    @ver = VERSION
    @score = File.read(@base_path).split.last.to_f
  end

  def get_result_table
    File.read(@base_path).split(/\r\n|\n/).map {|line| line.gsub(/\||-|\+/, "").split}.delete_if {|line| line.empty? || line.first == "平均得点"}
  end

  def self.create(data_dir)
    Dir::mkdir(data_dir)
    `mv #{Rails.root}/tmp/log/_tmp/Result.txt #{data_dir}`
    (data_dir + "/result.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base_path: "#{data_dir}/Result.txt"})
      end
    end
  end
end

