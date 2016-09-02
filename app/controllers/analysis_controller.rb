class AnalysisController < ApplicationController
  include GraphGenerator

  def list
    @leagues = League.active
  end

  def league
    @league = League.includes(players: [:submits, :strategies]).find(params[:lid])
    @column_strategies_per_day = column_strategies_per_day(@league.id)
    @line_strategies_total = line_strategies_total(@league.id)
  end

  def refresh
    @league = League.where(id: params[:lid]).first
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end

  def player
    @player = Player.find(params[:pid])
    @strategies = @player.strategies.number_by
    @line_score = line_score(@player.id)
  end

  def code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    @strategy = Player.find(params[:pid]).strategies.where(number: params[:num]).first
    @scatter_abc_size = scatter_abc_size(params[:lid], @strategy.id)
    @result_table = @strategy.get_result_table
  end

  def strategies
    @scatter_abc_size = scatter_abc_size(params[:lid])
  end

  def ranking
    league = League.includes(players: [{best: :strategy}, :strategies, :user, :submits]).find(params[:lid])
    @players = league.players_ranking
    @players += league.players.select {|p| !p.best}

    @strategies = league.strategies.sort { |a, b| b.score <=> a.score }
    @bar_submits = bar_submits(league.id)
  end
end

