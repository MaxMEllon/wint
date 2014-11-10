
class ResultAnalysis
  attr_reader :score, :result_amount

  VERSION = 1.0
  HAND = 10  # 役の数

  def initialize(path)
    data = ModelHelper.decode_json(File.read(path))
    @ver = data[:ver].to_f
    @base_path = data[:base_path]
    @score = data[:score].to_f
    @result_amount = data[:result_amount]
  end

  def latest?
    @ver >= VERSION
  end

  def update
    return if self.latest?
    @ver = VERSION
    @score = File.read(@base_path).split.last.to_f
    @result_amount = get_result_amount(self.get_result_table)
  end

  def get_result_table
    File.read(@base_path).split(/\r\n|\n/).map {|line| line.gsub(/\||-|\+/, "").split}.delete_if {|line| line.empty? || line.first == "平均得点"}
  end

  def self.create(data_dir, submit_id)
    Dir::mkdir(data_dir)
    `mv #{Rails.root}/tmp/log/_tmp#{submit_id}/Result.txt #{data_dir}`
    (data_dir + "/result.json").tap do |path|
      File.open(path, "w") do |f|
        f.puts ModelHelper.encode_json({ver: 0.0, base_path: "#{data_dir}/Result.txt"})
      end
    end
  end

  private
  def get_result_amount(table)
    table.shift  # 一番上の行を削除
    t = table.map {|t| t.last.to_i}
    {P0: t[0], P1: t[1], P2: t[2], P3: t[3], P4: t[4], P5: t[5], P6: t[6], P7: t[7], P8: t[8], P9: t[9]}
  end
end

