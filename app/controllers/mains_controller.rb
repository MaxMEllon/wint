class MainsController < ApplicationController
  def mypage
    @player = Player.where(user_id: session[:user_id], league_id: params[:lid]).first
  end

  def select
    user = User.where(id: session[:user_id]).first
    @players = user.players
  end
end

