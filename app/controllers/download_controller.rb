class DownloadController < ApplicationController
  before_action :mkdir, only: [:best_strategies, :all_strategies]

  ROOT_DIR = "#{Rails.root}/tmp/downloads"

  def best_strategies
    @league = League.where(id: params[:lid]).first
    tmp_dir = ROOT_DIR + "/best_strategies"
    Dir.mkdir(tmp_dir)

    @league.players.each do |player|
      next unless player.best
      `cp #{player.best.src_file} #{tmp_dir}/#{player.user.snum}.c`
    end
    `zip -j #{tmp_dir}.zip #{tmp_dir}/*`
    send_file "#{tmp_dir}.zip"
  end

  def all_strategies
    @league = League.where(id: params[:lid]).first
    tmp_dir = ROOT_DIR + "/all_strategies"
    Dir.mkdir(tmp_dir)

    @league.players.each do |player|
      player.submits.each.with_index(1) do |submit, i|
        filename = "#{player.user.snum}_%03d.c" % i
        `cp #{submit.src_file} #{tmp_dir}/#{filename}`
      end
    end
    `zip -j #{tmp_dir}.zip #{tmp_dir}/*`
    send_file "#{tmp_dir}.zip"
  end

  def best_analysis
    @league = League.where(id: params[:lid]).first
    @players = @league.players_ranking

    csv = ["学籍番号," + AnalysisManager.to_csv_header]
    @players.each do |player|
      analy = AnalysisManager.load(player.best.analysis_file)
      csv << player.user.snum + "," + analy.to_csv
    end

    filename = ROOT_DIR + "/best_analysis.csv"
    File.open(filename, "w") {|f| f.puts csv}
    `nkf -s --overwrite #{filename}`
    send_file filename
  end

  def all_analysis
    @league = League.where(id: params[:lid]).first

    csv = ["学籍番号," + AnalysisManager.to_csv_header]
    @league.players.each do |player|
      player.submits.each.with_index(1) do |submit, i|
        analy = AnalysisManager.load(submit.analysis_file)
        name = "#{player.user.snum}_%03d" % i
        csv << name + "," + analy.to_csv
      end
    end

    filename = ROOT_DIR + "/all_analysis.csv"
    File.open(filename, "w") {|f| f.puts csv}
    `nkf -s --overwrite #{filename}`
    send_file filename
  end

  private
  def mkdir
    `rm -rf #{ROOT_DIR}` if File.exist?(ROOT_DIR)
    Dir.mkdir(ROOT_DIR)
  end
end

