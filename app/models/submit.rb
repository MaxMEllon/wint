class Submit < ActiveRecord::Base
  belongs_to :player
  belongs_to :strategy

  validates_presence_of :data_dir

  STATUS_SUCCESS = 0
  STATUS_COMPILE_ERROR = 1
  STATUS_RUN_ERROR = 2

  def src_file
    self.data_dir + "/PokerOpe.c"
  end

  def exec_file
    self.data_dir + "/PokerOpe"
  end

  def get_number
    submits = self.player.submits
    submits.present? ? submits.last.number+1 : 1
  end

  def get_status
    league = self.player.league
    rules = league.rule
    compile(league.data_dir, rules, self.src_file, self.exec_file)
    return STATUS_COMPILE_ERROR unless File.exist?(self.exec_file)

    begin
      exec(league.data_dir, rules, self.exec_file)
    rescue
      return STATUS_RUN_ERROR
    end
    STATUS_SUCCESS
  end

  def mkdir
    (self.player.data_dir + "/%03d" % self.number).tap do |path|
      Dir::mkdir(path)
    end
  end

  def set_data(source)
    File.open(self.src_file, "w") {|f| f.puts source}
  end

  private
  def compile(data_dir, rules, src_file, exec_file)
    data_dir += "/rule"
    `gcc -O2 -I #{data_dir} #{src_file} #{data_dir}/PokerExec.c #{data_dir}/CardLib.c -DTYPE=#{"%02d" % rules[:take]}-#{"%02d" % rules[:change]} -DTAKE=#{rules[:take]} -DCHNG=#{rules[:change]} -o #{exec_file}`
  end

  def exec(data_dir, rules, exec_file)
    `cd #{Rails.root}/tmp && #{exec_file} _tmp #{rules[:try]} #{data_dir}/Stock.ini 0`
  end
end

