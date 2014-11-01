class MainsController < ApplicationController
  def ranking
    @league = League.where(id: session[:lid]).eager_load(players: {best: :strategy}).first
    @players = @league.players.select {|p| p.best}.sort {|a, b| b.best.strategy.score <=> a.best.strategy.score}
  end

  def mypage
    @submits = Submit.where(player_id: @current_player.id).eager_load(:strategy)
  end

  def strategy
    @strategy = @current_player.submits.where(number: params[:number]).first.strategy
    @result = AnalysisManager.new(@strategy.analy_file).result.get_result
  end

  def select
    @players = @current_user.players
  end

  def set_player
    session[:lid] = params[:lid]
    session[:pid] = Player.where(user_id: session[:uid], league_id: session[:lid]).first.id
    redirect_to main_mypage_path
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

