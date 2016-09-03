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

  def player_ranking
    @league = League.includes(players: [{best: :strategy}, :strategies, :user, :submits]).find(params[:lid])
    @players = @league.players_ranking
    @players += @league.players.select {|p| !p.best}
  end

  def strategy_ranking
    @league = League.includes(players: [{best: :strategy}, :strategies, :user, :submits]).find(params[:lid])

    @strategies = @league.strategies.sort { |a, b| b.score <=> a.score }
  end

  def player
    @lid = params[:lid]
    @player = Player.find(params[:pid])
    @strategies = @player.strategies.number_by
    @line_score = line_score(@player.id)
  end

  def code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    @lid = params[:lid]
    @strategy = Player.find(params[:pid]).strategies.where(number: params[:num]).first
    @scatter_abc_size = scatter_abc_size(@lid, @strategy.id)
    @result_table = @strategy.get_result_table
  end

  def strategies
    @lid = params[:lid]
    @scatter_abc_size = scatter_abc_size(params[:lid])
    @bar_submits = bar_submits(@lid)
  end

  def refresh
    @league = League.where(id: params[:lid]).first
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end
end

