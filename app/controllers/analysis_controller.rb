class AnalysisController < ApplicationController
  def list
    @leagues = League.active
  end

  def league
    @league = League.where(id: params[:lid]).first
  end

  def refresh
    @league = League.where(id: params[:lid]).first
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end
end

