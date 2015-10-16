# == Schema Information
#
# Table name: submits
#
#  id         :integer          not null, primary key
#  player_id  :integer          not null
#  data_dir   :string(255)      default(""), not null
#  comment    :string(255)
#  number     :integer          not null
#  status     :integer          default(0), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

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

  scope :number_by, -> { order('number') }
  Scope.active(self)

  def self.create(attributes)
    player = Player.find(attributes[:player_id])
    attributes[:number] = last_number(player)
    path = player.data_dir + format('/%03d', attributes[:number])
    FileUtils.mkdir(path)
    File.open(path + '/PokerOpe.c', 'w') { |f| f.puts attributes[:data_dir] }
    `nkf --overwrite -w #{path}/PokerOpe.c`
    attributes[:data_dir] = path
    super(attributes).tap do |submit|
      HardWorker.perform_async(submit.id)
    end
  end

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
    data_dir + '/PokerOpe.c'
  end

  def exec_file
    data_dir + '/PokerOpe'
  end

  def size_over?
    data_dir.size >= SIZE_LIMIT
  end

  def self.last_number(player)
    submits = player.submits.number_by
    submits.present? ? submits.last.number + 1 : 1
  end

  def filecheck
    status = ExecManager.filecheck(src_file)
    update(status: status)
    fail 'Syntax Error' if syntax_error?
  end

  def compile
    league = player.league
    status = ExecManager.compile(league.rule, src_file, exec_file)
    update(status: status)
    fail 'Compile Error' if compile_error?
  end

  def execute
    league = player.league
    status = ExecManager.exec(league.rule, exec_file, id)
    update(status: status)
    fail 'Execute Error' if execute_error?
  end

  def syntax_error?
    status == STATUS_SYNTAX_ERROR
  end

  def compile_error?
    status == STATUS_COMPILE_ERROR
  end

  def execute_error?
    status == STATUS_EXEC_ERROR
  end
end

