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
    @player = Player.where(id: params[:pid]).first
    @strategies = @player.strategies.number_by
    @league = League.where(id: @player.league_id).includes(players: [{best: :strategy}, :user]).first
    analysis = @league.players_ranking.map {|player| player.analysis_with_snum}

    dev_size = Deviation.new(analysis.map {|_, a| a.plot_size})
    dev_syntax = Deviation.new(analysis.map {|_, a| a.plot_syntax})
    dev_fun = Deviation.new(analysis.map {|_, a| a.plot_fun})
    dev_gzip = Deviation.new(analysis.map {|_, a| a.plot_gzip})

    @degrees = @strategies.map do |strategy|
      analy = AnalysisManager.new(strategy.analy_file)
      {
        size: dev_size.degree(analy.plot_size),
        syntax: dev_syntax.degree(analy.plot_syntax),
        fun: dev_fun.degree(analy.plot_fun),
        gzip: dev_gzip.degree(analy.plot_gzip)
      }
    end

    @line_score = GraphGenerator.line_score(@strategies.map {|s| [s.number, s.score]})
  end

  def best_code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
    analysis = @league.players_ranking.map {|player| player.analysis_with_snum}

    if analysis.blank?
      @scatter_size = @histgram_size = nil
    else
      dev_size = Deviation.new(analysis.map {|n, a| {name: n}.merge(a.plot_size)})
      dev_syntax = Deviation.new(analysis.map {|n, a| {name: n}.merge(a.plot_syntax)})
      dev_fun = Deviation.new(analysis.map {|n, a| {name: n}.merge(a.plot_fun)})
      dev_gzip = Deviation.new(analysis.map {|n, a| {name: n}.merge(a.plot_gzip)})
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
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :strategies, :user, :submits]).first
    @players = @league.players_ranking
    player_analysis = @players.map {|player| player.analysis_with_snum}

    strategies_analysis = []
    @players.each do |player|
      player.strategies.each do |strategy|
        strategies_analysis << [player.user.snum + "_%03d" % strategy.number, AnalysisManager.new(strategy.analy_file)]
      end
    end

    @players += @league.players.select {|p| !p.best}

    dev_size = Deviation.new(player_analysis.map {|_, a| a.plot_size})
    dev_syntax = Deviation.new(player_analysis.map {|_, a| a.plot_syntax})
    dev_fun = Deviation.new(player_analysis.map {|_, a| a.plot_fun})
    dev_gzip = Deviation.new(player_analysis.map {|_, a| a.plot_gzip})

    @player_degrees = player_analysis.map do |name, analy|
      {
        name: name,
        size: dev_size.degree(analy.plot_size),
        syntax: dev_syntax.degree(analy.plot_syntax),
        fun: dev_fun.degree(analy.plot_fun),
        gzip: dev_gzip.degree(analy.plot_gzip)
      }
    end

    @strategies_degrees = strategies_analysis.map do |name, analy|
      {
        name: name,
        score: analy.result.score,
        size: dev_size.degree(analy.plot_size),
        syntax: dev_syntax.degree(analy.plot_syntax),
        fun: dev_fun.degree(analy.plot_fun),
        gzip: dev_gzip.degree(analy.plot_gzip)
      }
    end

    @bar_submits = GraphGenerator.bar_submits(@players.map {|p| [p.user.snum, p.strategies.to_a.count]})
  end
end

