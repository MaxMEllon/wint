class MainsController < ApplicationController
  def ranking
    players = Player.where(league_id: current_player.league_id)
    @bests = players.map {|p| p.best}.sort {|a, b| b.strategy.score <=> a.strategy.score}
  end

  def mypage
    @player = current_player
  end

  def select
    @players = current_user.players
  end

  def set_player
    session[:lid] = params[:lid]
    session[:pid] = Player.where(user_id: session[:uid], league_id: session[:lid]).first.id
    redirect_to main_mypage_path
  end
end

