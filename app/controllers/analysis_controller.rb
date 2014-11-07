class AnalysisController < ApplicationController
  include GraphGenerator
  before_action :get_league, only: [:league, :refresh, :strategy]

  def list
    @leagues = League.active
  end

  def league
    sum = @league.start_at
    per_day = []
    total = [0]
    strategies = @league.players.map {|p| p.strategies}.flatten
    while sum < @league.end_at
      per_day << strategies.select {|s| sum <= s.created_at && s.created_at < sum+1.days}.count
      total << per_day.last + total.last if sum < Time.new
      sum += 1.days
    end
    total.shift
    @column_strategies_per_day = GraphGenerator.column_strategies_per_day(per_day, @league.start_at)
    @column_strategies_total = GraphGenerator.column_strategies_total(total, @league.start_at)
  end

  def refresh
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end

  def player
    @player = Player.where(id: params[:pid]).first
    data = @player.strategies.map {|s| [s.number, s.score]}
    @strategies = @player.strategies
    @league = @player.league
    @line_score = GraphGenerator.line_score(data)
  end

  def best_code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
    analysis = players.map do |player|
      [player.user.snum, AnalysisManager.new(player.best.strategy.analy_file)]
    end

    if analysis.blank?
      @scatter_size = @histgram_size = nil
    else
      dev_size = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.size}})
      dev_syntax = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.count[:loop] + a.code.count[:if]}})
      dev_fun = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.func_num}})
      dev_gzip = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: (1-(a.code.gzip_size / a.code.size.to_f))*100}})
      #-- size
      @scatter_size = GraphGenerator.scatter_size(dev_size)
      @histgram_size = GraphGenerator.histgram(dev_size)
      #-- syntax
      @scatter_syntax = GraphGenerator.scatter_syntax(dev_syntax)
      @histgram_syntax = GraphGenerator.histgram(dev_syntax)
      #-- fun
      @scatter_fun = GraphGenerator.scatter_fun(dev_fun)
      @histgram_fun = GraphGenerator.histgram(dev_fun)
      #-- gzip
      @scatter_gzip = GraphGenerator.scatter_gzip(dev_gzip)
      @histgram_gzip = GraphGenerator.histgram(dev_gzip)
    end
  end

  def ranking
    @league = League.where(id: params[:lid]).eager_load(players: {best: :strategy}).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
    @players += @league.players.select {|p| !p.best}

    data = @players.map {|p| [p.user.snum, p.strategies.count]}
    @bar_submits = GraphGenerator.bar_submits(data)
  end

  private
  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

