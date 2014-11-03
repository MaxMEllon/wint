class AnalysisController < ApplicationController
  include GraphGenerator
  before_action :get_league, only: [:league, :refresh, :strategy]

  def list
    @leagues = League.active
  end

  def league
  end

  def refresh
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end

  def strategy
    #data = @league.players.active.select {|p| p.best}.map do |player|
    #  strategy = player.best.strategy
    #  analy = AnalysisManager.new(player.best.strategy.analy_file)
    #  {name: player.user.snum, x: ("%.2f" % analy.result.score).to_f, y: analy.code.line}
    #end.sort {|a, b| a[:x] <=> b[:x]}

    # debug
    strategies = @league.players.first.strategies
    data = strategies.map do |strategy|
      analy = AnalysisManager.new(strategy.analy_file)
      {name: "s11t230", x: ("%.2f" % analy.result.score).to_f, y: analy.code.line}
    end.sort {|a, b| a[:x] <=> b[:x]}

    func = LinearRegression.new(data.map {|d| d[:x]}, data.map {|d| d[:y]})
    @scatter_line = GraphGenerator.scatter_line_with_regression(data, func)
  end

  def ranking
    @league = League.where(id: params[:lid]).eager_load(players: {best: :strategy}).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
    @players += @league.players.select {|p| !p.best}
  end

  private
  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

