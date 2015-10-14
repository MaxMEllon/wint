require 'rake'

module ExecManager

  def filecheck(src_file)
    File.read(src_file).split(/\r\n|\n/).each do |line|
      return Submit::STATUS_SYNTAX_ERROR if line =~ /system/
    end
    Submit::STATUS_SUCCESS
  end

  def compile(rule, src_file, exec_file)
    take = format('%02d', rule.take)
    change = format('%02d', rule.change)
    Rake::sh "gcc -O2 -w -I #{rule.path} #{src_file} #{rule.path}/PokerExec.c #{rule.path}/CardLib.c -DTYPE=#{take}-#{change} -DTAKE=#{rule.take} -DCHNG=#{rule.change} -o #{exec_file}", verbose: false rescue return Submit::STATUS_COMPILE_ERROR
    Submit::STATUS_SUCCESS
  end

  def exec(rule, exec_file, submit_id)
    tmp_path = "#{Rails.root}/tmp/log/_tmp#{submit_id}"
    FileUtils.mkdir("#{Rails.root}/tmp/log") unless File.exist?("#{Rails.root}/tmp/log")
    FileUtils.mkdir(tmp_path) unless File.exist?(tmp_path)
    begin
      Timeout.timeout(Submit::TIME_LIMIT) do
        volume_stock = "-v #{rule.path}/Stock.ini:/var/tmp/Stock.ini"
        volume_exec = "-v #{exec_file}:/var/tmp/PokerOpe"
        exec_command = "mkdir /var/tmp/log && cd /var/tmp && /var/tmp/PokerOpe _tmp #{rule.try} /var/tmp/Stock.ini 1"
        command = ""
        if ENV['CIRCLECI']
          command = "docker run #{volume_stock} #{volume_exec} ubuntu:14.04 /bin/bash -c '#{exec_command}'"
        else
          command = "docker run --rm #{volume_stock} #{volume_exec} ubuntu:14.04 /bin/bash -c '#{exec_command}'"
        end
        stdout, stderr, thread = Open3.capture3(command)
        return Submit::STATUS_EXEC_ERROR unless stderr.blank?
        game_log, result = stdout.split(/\r\n\r\n|\n\n/)
        File.open(tmp_path + '/Game.log', 'w') { |f| f.puts game_log }
        File.open(tmp_path + '/Result.txt', 'w') { |f| f.puts result }
      end
    rescue
      return Submit::STATUS_TIME_OVER
    end
    Submit::STATUS_SUCCESS
  end

  module_function :filecheck, :compile, :exec
end

