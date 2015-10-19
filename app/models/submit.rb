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

  module Status
    RUNNING = 0
    SUCCESS = 1
    COMPILE_ERROR = 2
    RUNTIME_ERROR = 3
    TIME_ERROR = 4
    SYNTAX_ERROR = 5
  end

  TIME_LIMIT = 30
  SIZE_LIMIT = 100.kilobytes

  module FileName
    SOURCE = 'PokerOpe.c'
    EXEC = 'PokerOpe'
  end

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
      Status::RUNNING => '実行中',
      Status::SUCCESS => '成功',
      Status::COMPILE_ERROR => 'コンパイルエラー',
      Status::RUNTIME_ERROR => '実行時エラー',
      Status::TIME_ERROR => '時間超過',
      Status::SYNTAX_ERROR => '危険なコード'
    }
  end

  def src_file
    "#{data_dir}/#{FileName::SOURCE}"
  end

  def exec_file
    "#{data_dir}/#{FileName::EXEC}"
  end

  def size_over?
    data_dir.size >= SIZE_LIMIT
  end

  def self.last_number(player)
    submits = player.submits.number_by
    submits.present? ? submits.last.number + 1 : 1
  end

  def filecheck
    File.read(src_file).split(/\r\n|\n/).each do |line|
      next unless line =~ /system/
      update(status: Status::SYNTAX_ERROR)
      fail 'Syntax Error'
    end
  end

  def compile
    rule = player.league.rule
    cmd = rule.compile_command(src_file, exec_file)
    Rake::sh cmd, verbose: false
  rescue
    update(status: Status::COMPILE_ERROR)
    raise 'Compile Error'
  end

  def execute
    rule = player.league.rule
    status = ExecManager.exec(league.rule, exec_file, id)
    update(status: status)
    fail 'Execute Error' if execute_error?
  end

  def syntax_error?
    status == Status::SYNTAX_ERROR
  end

  def compile_error?
    status == Status::COMPILE_ERROR
  end

  def execute_error?
    status == Status::RUNTIME_ERROR
  end
end

