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

require 'rake'
require 'open3'

class Submit < ActiveRecord::Base
  class PokerCompileError < StandardError; end
  class PokerExecuteError < StandardError; end
  class PokerTimeoutError < StandardError; end
  class PokerSyntaxError < StandardError; end

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

  after_create do
    num = last_number
    path = format("#{player.data_dir}/%03d", num)
    Dir.mkdir(path)
    File.write("#{path}/PokerOpe.c", data_dir)
    `nkf --overwrite -w #{path}/PokerOpe.c`
    update(data_dir: path, number: num)
    HardWorker.perform_async(id)
  end

  def src_file
    data_dir + '/PokerOpe.c'
  end

  def exec_file
    data_dir + '/PokerOpe'
  end

  def analysis_path
    data_dir + '/analy'
  end

  def perform
    syntax_check
    compile
    execute
    update(status: STATUS_SUCCESS)
  rescue PokerSyntaxError
    update(status: STATUS_SYNTAX_ERROR)
  rescue PokerCompileError
    update(status: STATUS_COMPILE_ERROR)
  rescue PokerExecuteError
    update(status: STATUS_EXEC_ERROR)
  rescue PokerTimeoutError
    update(status: STATUS_TIME_OVER)
  end

  def exec_success?
    status == STATUS_SUCCESS
  end

  private

  def last_number
    submits = player.submits.number_by
    submits.present? ? submits.last.number + 1 : 1
  end

  def syntax_check
    File.read(src_file).split(/\r\n|\n/).each do |line|
      fail PokerSyntaxError if line =~ /system/
    end
  end

  def compile
    league = player.league
    Rake.sh league.compile_command(src_file, exec_file)
  rescue RuntimeError
    raise PokerCompileError
  end

  def execute
    league = player.league
    Dir.mkdir("#{Rails.root}/tmp/log") unless File.exist?("#{Rails.root}/tmp/log")

    cmd = league.execute_command(exec_file, id)
    Open3.popen3(cmd, pgroup: true) do |_stdin, _stdout, stderr, thread|
      begin
        Timeout.timeout(TIME_LIMIT, PokerTimeoutError) do
          fail PokerExecuteError unless stderr.read.blank?
        end
      rescue PokerTimeoutError
        Process.kill(:TERM, -thread.pid)
        raise PokerTimeoutError
      end
    end
  end

  public_class_method

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

  def self.create(attributes)
    attributes[:data_dir] = nil if attributes[:data_dir].size >= SIZE_LIMIT
    attributes[:number] = 0
    super(attributes)
  end
end

