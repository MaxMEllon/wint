require "analysis/analysis_manager"
require "graph_generator"

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
    #data = @league.players.active.map do |player|
    #  next unless player.best
    #  strategy = player.best.strategy
    #  analy = AnalysisManager.new(player.best.strategy.analy_file)
    #  {name: player.user.snum, x: "%.2f" % analy.result.score, y: analy.code.line}
    #end

    # debug
    strategies = @league.players.first.strategies
    data = strategies.map do |strategy|
      analy = AnalysisManager.new(strategy.analy_file)
      {name: "s11t230", x: "%.2f" % analy.result.score, y: analy.code.line}
    end
    @graph_data = GraphGenerator.scatter_line(data)
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

