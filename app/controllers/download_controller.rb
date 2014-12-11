class DownloadController < ApplicationController
  before_action :mkdir, only: [:best_strategies, :all_strategies]

  ROOT_DIR = "#{Rails.root}/tmp/downloads"

  def best_strategies
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
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
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, {strategies: :submit}, :user]).first
    tmp_dir = ROOT_DIR + "/all_strategies"
    Dir.mkdir(tmp_dir)

    @league.players.each do |player|
      next unless player.best
      player.strategies.each do |strategy|
        filename = "#{player.user.snum}_%03d.c" % strategy.number
        `cp #{strategy.submit.src_file} #{tmp_dir}/#{filename}`
      end
    end
    `zip -j #{tmp_dir}.zip #{tmp_dir}/*`
    send_file "#{tmp_dir}.zip"
  end

  def best_analysis
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :strategies, :user]).first
    @players = @league.players_ranking
    csv = [AnalysisManager.to_csv_header]
    @players.each do |player|
      analy = AnalysisManager.new(player.best.strategy.analy_file)
      csv << analy.to_csv
    end
    filename = ROOT_DIR + "/best_analysis.csv"
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

