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
    analysis = @league.players_ranking.map {|player| player.analysis_with_snum}

    dev_size = Deviation.new(@strategies.map {|s| s.plot_size})
    dev_syntax = Deviation.new(@strategies.map {|s| s.plot_syntax})
    dev_fun = Deviation.new(@strategies.map {|s| s.plot_fun})
    dev_gzip = Deviation.new(@strategies.map {|s| s.plot_gzip})

    @degrees = @strategies.map do |strategy|
      {
        size: dev_size.degree(strategy.plot_size),
        syntax: dev_syntax.degree(strategy.plot_syntax),
        fun: dev_fun.degree(strategy.plot_fun),
        gzip: dev_gzip.degree(strategy.plot_gzip)
      }
    end

    @line_score = GraphGenerator.line_score(@strategies.map {|s| [s.number, s.score]})
  end

  def code
    @submit = Submit.where(id: params[:sid]).first
  end

  def strategy
    league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
    players_ranking = league.players_ranking

    @strategy = league.players.where(id: params[:pid]).first.strategies.where(number: params[:num]).first

    dev_size = Deviation.new(players_ranking.map {|p| p.best.strategy.plot_size})
    dev_syntax = Deviation.new(players_ranking.map {|p| p.best.strategy.plot_syntax})
    dev_fun = Deviation.new(players_ranking.map {|p| p.best.strategy.plot_fun})
    dev_gzip = Deviation.new(players_ranking.map {|p| p.best.strategy.plot_gzip})

    player_size = @strategy.plot_size
    player_syntax = @strategy.plot_syntax
    player_fun = @strategy.plot_fun
    player_gzip = @strategy.plot_gzip

    @scatter_size = GraphGenerator.scatter_size(dev_size, [player_size.values])
    @scatter_syntax = GraphGenerator.scatter_syntax(dev_syntax, [player_syntax.values])
    @scatter_fun = GraphGenerator.scatter_fun(dev_fun, [player_fun.values])
    @scatter_gzip = GraphGenerator.scatter_gzip(dev_gzip, [player_gzip.values])

    data = [
      {x: "ファイルサイズ", y: dev_size.degree(player_size)},
      {x: "制御構文の条件の数", y: dev_size.degree(player_syntax)},
      {x: "関数の宣言数", y: dev_size.degree(player_fun)},
      {x: "圧縮率", y: dev_size.degree(player_gzip)}
    ]
    @polar_dev = GraphGenerator.polar_dev(data)

    @result_table = @strategy.get_result_table
  end

  def strategies
    @league = League.where(id: params[:lid]).includes(players: [{best: :strategy}, :user]).first
    player_ranking = @league.players_ranking

    if player_ranking.blank?
      @scatter_size = @histgram_size = nil
    else
      dev_size = Deviation.new(player_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_size)})
      dev_syntax = Deviation.new(player_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_syntax)})
      dev_fun = Deviation.new(player_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_fun)})
      dev_gzip = Deviation.new(player_ranking.map {|p| {name: p.snum}.merge(p.best.strategy.plot_gzip)})
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

    @players += @league.players.select {|p| !p.best}

    dev_size = Deviation.new(@players.map {|p| p.best.strategy.plot_size})
    dev_syntax = Deviation.new(@players.map {|p| p.best.strategy.plot_syntax})
    dev_fun = Deviation.new(@players.map {|p| p.best.strategy.plot_fun})
    dev_gzip = Deviation.new(@players.map {|p| p.best.strategy.plot_gzip})

    @player_degrees = @players.map do |player|
      {
        name: player.snum,
        size: dev_size.degree(player.best.strategy.plot_size),
        syntax: dev_syntax.degree(player.best.strategy.plot_syntax),
        fun: dev_fun.degree(player.best.strategy.plot_fun),
        gzip: dev_gzip.degree(player.best.strategy.plot_gzip)
      }
    end

    strategies = @players.map { |player| player.strategies }.flatten.sort { |a, b| a.score <=> b.score }
    @strategies_degrees = strategies.map do |strategy|
      {
        name: strategy.player.snum,
        score: strategy.score,
        size: dev_size.degree(strategy.plot_size),
        syntax: dev_syntax.degree(strategy.plot_syntax),
        fun: dev_fun.degree(strategy.plot_fun),
        gzip: dev_gzip.degree(strategy.plot_gzip)
      }
    end

    @bar_submits = GraphGenerator.bar_submits(@players.map {|p| [p.user.snum, p.strategies.to_a.count]})
  end
end

