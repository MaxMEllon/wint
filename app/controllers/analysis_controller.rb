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

    data_size = analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.size}}
    data_syntax = analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.count[:loop] + a.code.count[:if]}}
    data_fun = analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.func_num}}

    if data_size.blank?
      @scatter_size = @histgram_size = nil
    else
      #-- size
      func_size = LinearRegression.new(data_size.map {|d| d[:x]}, data_size.map {|d| d[:y]})
      @scatter_size = GraphGenerator.scatter_size(data_size, func_size)
      @histgram_size = GraphGenerator.histgram(data_size, func_size)
      #-- syntax
      func_syntax = LinearRegression.new(data_syntax.map {|d| d[:x]}, data_syntax.map {|d| d[:y]})
      @scatter_syntax = GraphGenerator.scatter_syntax(data_syntax, func_syntax)
      @histgram_syntax = GraphGenerator.histgram(data_syntax, func_syntax)
      #-- fun
      func_fun = LinearRegression.new(data_fun.map {|d| d[:x]}, data_fun.map {|d| d[:y]})
      @scatter_fun = GraphGenerator.scatter_fun(data_fun, func_fun)
      @histgram_fun = GraphGenerator.histgram(data_fun, func_fun)
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

