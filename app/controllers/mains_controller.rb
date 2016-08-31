class MainsController < ApplicationController
  def ranking
    @league = League.where(id: session[:lid]).eager_load(players: {best: :strategy}).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
  end

  def mypage
    @player = @current_player
    @submits = Submit.where(player_id: @player.id).eager_load(:strategy)
    @league = @player.league
    @line_score = GraphGenerator.line_score(@player.strategies.number_by.map {|s| [s.number, s.score]})
  end

  def strategy
    @player = @current_player
    @strategy = @player.submits.where(number: params[:num]).first.strategy

    league = League.where(id: @player.league_id).includes(players: [{best: :strategy}, :user, :submits, :strategies]).first
    players = league.players_ranking

    dev_abc_size = Deviation.new(players.map {|p| p.best.strategy.plot_abc_size})
    player_abc_size = @strategy.plot_abc_size
    @scatter_abc_size = GraphGenerator.scatter_abc_size(dev_abc_size, [player_abc_size.values])

    @result_table = @strategy.get_result_table
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

