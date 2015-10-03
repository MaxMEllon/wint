require "rake"

module ExecManager

  def filecheck(src_file)
    File.read(src_file).split(/\r\n|\n/).each do |line|
      return Submit::STATUS_SYNTAX_ERROR if line =~ /system/
    end
    Submit::STATUS_SUCCESS
  end

  def compile(rule_dir, rules, src_file, exec_file)
    take = "%02d" % rules[:take]
    change = "%02d" % rules[:change]
    Rake::sh "gcc -O2 -w -I #{rule_dir} #{src_file} #{rule_dir}/PokerExec.c #{rule_dir}/CardLib.c -DTYPE=#{take}-#{change} -DTAKE=#{rules[:take]} -DCHNG=#{rules[:change]} -o #{exec_file}" rescue return Submit::STATUS_COMPILE_ERROR
    Submit::STATUS_SUCCESS
  end

  def exec(rule_dir, rules, exec_file, submit_id)
    Dir::mkdir("#{Rails.root}/tmp/log") unless File.exist?("#{Rails.root}/tmp/log")
    begin
      Timeout.timeout(Submit::TIME_LIMIT) do
        Rake::sh "cd #{Rails.root}/tmp && #{exec_file} _tmp#{submit_id} #{rules[:try]} #{rule_dir}/Stock.ini 0" rescue return Submit::STATUS_EXEC_ERROR
      end
    rescue
      return Submit::STATUS_TIME_OVER
    end
    Submit::STATUS_SUCCESS
  end

  module_function :filecheck, :compile, :exec
end

