class MainsController < ApplicationController
  def ranking
    @league = League.where(id: session[:lid]).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.score <=> a.best.score}
  end

  def mypage
    @player = @current_player
    @submits = Submit.where(player_id: @player.id)
    @league = @player.league
    @line_score = GraphGenerator.line_score(@player.submits.number_by.map {|s| [s.number, s.score]})
  end

  def strategy
    @player = @current_player
    @submit = @player.submits.where(number: params[:num]).first
    player_analy = AnalysisManager.new(@submit.analysis_file)

    league = League.where(id: @player.league_id).first
    players = league.players_ranking
    analysis = players.map {|player| player.analysis_with_snum}

    dev_size = Deviation.new(analysis.map {|_, a| a.plot_size})
    dev_syntax = Deviation.new(analysis.map {|_, a| a.plot_syntax})
    dev_fun = Deviation.new(analysis.map {|_, a| a.plot_fun})
    dev_gzip = Deviation.new(analysis.map {|_, a| a.plot_gzip})

    player_size = player_analy.plot_size
    player_syntax = player_analy.plot_syntax
    player_fun = player_analy.plot_fun
    player_gzip = player_analy.plot_gzip

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

    @result_table = player_analy.result.get_result_table
  end

  def select
    @players = @current_user.players
  end

  def set_player
    player = Player.where(id: params[:pid]).first
    unless @current_user.id == player.user.id
      @current_user.update(is_active: false)
      redirect_to login_path, alert: "不正なアクセスを検出しました。" and return
    end
    session[:pid] = player.id
    session[:lid] = player.league.id
    redirect_to main_mypage_path and return
  end

  def edit_name
    @player = @current_player
  end

  def update_name
    @player = @current_player
    render :edit_name and return unless @player.update(player_params)
    render "shared/reload"
  end

  def edit_password
    @user = @current_user
  end

  def update_password
    @user = @current_user
    render :edit_password and return unless @user.update(user_params)
    render "shared/reload"
  end

  private
  def player_params
    params.require(:player).permit(:name)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

