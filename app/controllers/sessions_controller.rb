class SessionsController < ApplicationController
  def new
  end

  def create
    attr = params[:user]
    user = User.where(snum: attr[:snum]).first
    if user && user.authenticate(attr[:password])
      session[:user_id] = user.id
      redirect_to leagues_path and return
    else
      flash.now.alert = "ログイン失敗"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to leagues_path
  end
end
