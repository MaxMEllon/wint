module Executer
  class SyntaxError < StandardError; end
  class CompileError < StandardError; end
  class ExecuteError < StandardError; end

  def syntax_check(src)
    src.split(/\r\n|\n/).each do |line|
      fail SyntaxError, 'Syntax Error' if line =~ /system/
    end
  end

  def compile(cmd)
    _stdout, stderr, _thread = Open3.capture3(cmd)
    fail CompileError, stderr unless stderr.blank?
  end

  def execute(cmd, time_limit)
    stdout = stderr = thread = nil
    Timeout.timeout(time_limit) do
      stdout, stderr, thread = Open3.capture3(cmd)
      fail ExecuteError, stderr unless stderr.blank?
    end
    stdout
  end
end

