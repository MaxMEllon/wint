class MainsController < ApplicationController
  def ranking
    @league = League.where(id: session[:lid]).eager_load(players: {best: :strategy}).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
  end

  def mypage
    @player = @current_player
    @submits = Submit.where(player_id: @player.id).eager_load(:strategy)
    @league = @player.league
    data = @player.strategies.map {|s| [s.number, s.score]}
    @line_score = GraphGenerator.line_score(data)
  end

  def strategy
    @player = @current_player
    @strategy = @player.submits.where(number: params[:num]).first.strategy
    analy = AnalysisManager.new(@strategy.analy_file)

    players = @player.league.players.select {|p| p.id != @player.id && p.best }.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
    analysis = players.map do |player|
      [player.user.snum, AnalysisManager.new(player.best.strategy.analy_file)]
    end

    dev_size = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.size}})
    dev_syntax = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.count[:loop] + a.code.count[:if]}})
    dev_fun = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: a.code.func_num}})
    dev_gzip = Deviation.new(analysis.map {|n, a| {name: n, x: a.result.score, y: (1-(a.code.gzip_size / a.code.size.to_f))*100}})

    data_size = [analy.result.score, analy.code.size]
    data_syntax = [analy.result.score, analy.code.count[:loop] + analy.code.count[:if]]
    data_fun = [analy.result.score, analy.code.func_num]
    data_gzip = [analy.result.score, (1-(analy.code.gzip_size / analy.code.size.to_f))*100]
    @scatter_size = GraphGenerator.scatter_size(dev_size, [data_size])
    @scatter_syntax = GraphGenerator.scatter_syntax(dev_syntax, [data_syntax])
    @scatter_fun = GraphGenerator.scatter_fun(dev_fun, [data_fun])
    @scatter_gzip = GraphGenerator.scatter_gzip(dev_gzip, [data_gzip])
    data = [
      {x: "ファイルサイズ", y: dev_size.get_deviation_degree(data_size[0], data_size[1])},
      {x: "制御構文の条件の数", y: dev_size.get_deviation_degree(data_syntax[0], data_syntax[1])},
      {x: "関数の宣言数", y: dev_size.get_deviation_degree(data_fun[0], data_fun[1])},
      {x: "圧縮率", y: dev_size.get_deviation_degree(data_gzip[0], data_gzip[1])}
    ]
    @polar_dev = GraphGenerator.polar_dev(data)

    @result_table = analy.result.get_result_table
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

