class Submit < ActiveRecord::Base
  belongs_to :player
  has_one :strategy

  validates_presence_of :data_dir

  STATUS_RUNNINNG = 0
  STATUS_SUCCESS = 1
  STATUS_COMPILE_ERROR = 2
  STATUS_EXEC_ERROR = 3

  def self.status_options
    {
      STATUS_RUNNINNG => '実行中',
      STATUS_SUCCESS => '成功',
      STATUS_COMPILE_ERROR => 'コンパイルエラー',
      STATUS_EXEC_ERROR => '実行時エラー'
    }
  end

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
    rule_dir = league.data_dir + "/rule"
    compile(rule_dir, rules, self.src_file, self.exec_file)
    return STATUS_COMPILE_ERROR unless File.exist?(self.exec_file)

    begin
      exec(rule_dir, rules, self.exec_file)
    rescue
      return STATUS_EXEC_ERROR
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

  def exec_success?
    self.status == STATUS_SUCCESS
  end

  private
  def compile(rule_dir, rules, src_file, exec_file)
    `gcc -O2 -I #{rule_dir} #{src_file} #{rule_dir}/PokerExec.c #{rule_dir}/CardLib.c -DTYPE=#{"%02d" % rules[:take]}-#{"%02d" % rules[:change]} -DTAKE=#{rules[:take]} -DCHNG=#{rules[:change]} -o #{exec_file}`
  end

  def exec(rule_dir, rules, exec_file)
    log = "#{Rails.root}/tmp/log"
    Dir::mkdir(log) unless File.exist?(log)
    `cd #{Rails.root}/tmp && #{exec_file} _tmp #{rules[:try]} #{rule_dir}/Stock.ini 0`
  end
end

