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
    data = @league.players.active.select {|p| p.best}.map do |player|
      strategy = player.best.strategy
      analy = AnalysisManager.new(player.best.strategy.analy_file)
      # {name: player.user.snum, x: analy.result.score, y: analy.code.line}  # line
      {name: player.user.snum, x: analy.result.score, y: analy.code.size}
    end.sort {|a, b| a[:x] <=> b[:x]}

    if data.blank?
      # @scatter_line = @histgram_line = nil  # line
      @scatter_size = @histgram_size = nil
    else
      func = LinearRegression.new(data.map {|d| d[:x]}, data.map {|d| d[:y]})
      # line
      # @scatter_line = GraphGenerator.scatter_line(data, func)
      # @histgram_line = GraphGenerator.histgram_line(data, func)
      # size
      @scatter_size = GraphGenerator.scatter_size(data, func)
      @histgram_size = GraphGenerator.histgram_size(data, func)
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

