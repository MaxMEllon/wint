class SessionsController < ApplicationController
  def new
  end

  def create
    attr = params[:user]
    user = User.where(snum: attr[:snum]).first
    if user && user.authenticate(attr[:password])
      session[:uid] = user.id
      redirect_to main_select_path and return
    else
      flash.now.alert = "ログイン失敗"
      render :new
    end
  end

  def destroy
    session[:uid] = session[:lid] = session[:pid] = nil
    redirect_to login_path
  end
end

