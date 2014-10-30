class Submit < ActiveRecord::Base
  include ExecManager

  STATUS_RUNNING = 0
  STATUS_SUCCESS = 1
  STATUS_COMPILE_ERROR = 2
  STATUS_EXEC_ERROR = 3
  STATUS_TIME_OVER = 4
  STATUS_SYNTAX_ERROR = 5

  TIME_LIMIT = 30
  SIZE_LIMIT = 100.kilobytes

  belongs_to :player
  has_one :strategy

  validates_presence_of :data_dir
  validates_length_of :comment, maximum: 20

  scope :number_by, -> {order("number")}
  Scope.active(self)

  def self.status_options
    {
      STATUS_RUNNING => '実行中',
      STATUS_SUCCESS => '成功',
      STATUS_COMPILE_ERROR => 'コンパイルエラー',
      STATUS_EXEC_ERROR => '実行時エラー',
      STATUS_TIME_OVER => '時間超過',
      STATUS_SYNTAX_ERROR => '危険なコード'
    }
  end

  def src_file
    self.data_dir + "/PokerOpe.c"
  end

  def exec_file
    self.data_dir + "/PokerOpe"
  end

  def size_over?
    self.data_dir.size >= SIZE_LIMIT
  end

  def get_number
    submits = self.player.submits.number_by
    submits.present? ? submits.last.number+1 : 1
  end

  def get_status
    league = self.player.league
    rules = league.rule
    rule_dir = league.data_dir + "/rule"

    status = filecheck(self.src_file)
    return status unless status == STATUS_SUCCESS
    status = compile(rule_dir, rules, self.src_file, self.exec_file)
    return status unless status == STATUS_SUCCESS
    status = exec(rule_dir, rules, self.exec_file)
    return status unless status == STATUS_SUCCESS
    STATUS_SUCCESS
  end

  def mkdir
    (self.player.data_dir + "/%03d" % self.number).tap do |path|
      Dir::mkdir(path)
    end
  end

  def set_data(source)
    File.open(self.src_file, "w") {|f| f.puts source}
    `nkf --overwrite -w #{self.src_file}`
  end

  def exec_success?
    self.status == STATUS_SUCCESS
  end
end

