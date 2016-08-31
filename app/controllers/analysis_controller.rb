class AnalysisController < ApplicationController
  include GraphGenerator

  def list
    @leagues = League.active
  end

  def league
    @league = League.where(id: params[:lid]).includes(players: [:submits, :strategies]).first
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
    @league = League.where(id: params[:lid]).first
    @league.players.each do |player|
      player.strategies.each { |strategy| strategy.analysis_update }
    end
    redirect_to analysis_league_path
  end

  def player
    @player = Player.where(id: params[:pid]).includes(strategies: :submit).first
    @strategies = @player.strategies.number_by
    @league = League.where(id: @player.league_id).includes(players: [{best: :strategy}, :user]).first

    @line_score = GraphGenerator.line_score(@strategies.map {|s| [s.number, s.score]})
  end

  def code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
    players_ranking = league.players_ranking

    @strategy = league.players.where(id: params[:pid]).first.strategies.where(number: params[:num]).first

    dev_abc_size = Deviation.new(players_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_abc_size)})
    player_abc_size = @strategy.plot_abc_size

    @scatter_abc_size = GraphGenerator.scatter_abc_size(dev_abc_size, [player_abc_size.values])

    @result_table = @strategy.get_result_table
  end

  def strategies
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
    player_ranking = @league.players_ranking

    if player_ranking.blank?
      @scatter_abc_size = @histgram_abc_size = nil
    else
      dev_abc_size = Deviation.new(player_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_abc_size)})
      @scatter_abc_size = GraphGenerator.scatter_abc_size(dev_abc_size)
      @histgram_abc_size = GraphGenerator.histgram(dev_abc_size)
    end
  end

  def ranking
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :strategies, :user, :submits]).first
    @players = @league.players_ranking
    @players += @league.players.select {|p| !p.best}

    @strategies = @players.map { |player| player.strategies }.flatten.sort { |a, b| b.score <=> a.score }

    @bar_submits = GraphGenerator.bar_submits(@players.map {|p| [p.user.snum, p.strategies.count]})
  end
end

