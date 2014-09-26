class MainsController < ApplicationController
  def mypage
    @player = Player.where(user_id: session[:user_id], league_id: params[:lid]).first
  end
end

