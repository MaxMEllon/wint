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
  include Executer

  module Status
    RUNNING = 0
    SUCCESS = 1
    COMPILE_ERROR = 2
    RUNTIME_ERROR = 3
    TIME_ERROR = 4
    SYNTAX_ERROR = 5
  end

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
    File.open("#{path}/#{FileName::SOURCE}", 'w') { |f| f.puts attributes[:data_dir] }
    `nkf --overwrite -w #{path}/#{FileName::SOURCE}`
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

  def best?
    analy = AnalysisManager.new(analysis_file)
    true
    # submits = player.submits
    # return true if strategies.blank? || score >= strategies.first.score
    # false
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

  def perform
    rule = player.league.rule
    syntax_check(File.read(src_file))
    compile(rule.compile_command(src_file, exec_file))
    execute(rule.execute_command(exec_file), Rule::TIME_LIMIT).tap do
      update(status: Status::SUCCESS)
    end
  rescue SyntaxError
    update(status: Status::SYNTAX_ERROR) && nil
  rescue CompileError
    update(status: Status::COMPILE_ERROR) && nil
  rescue ExecuteError
    update(status: Status::RUNTIME_ERROR) && nil
  rescue Timeout::Error
    update(status: Status::TIME_ERROR) && nil
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

