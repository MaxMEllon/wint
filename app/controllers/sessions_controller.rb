class SessionsController < ApplicationController
  def new
    session[:uid] = session[:lid] = session[:pid] = nil
  end

  def create
    attr = params[:user]
    user = User.where(snum: attr[:snum]).active.first
    if user && user.authenticate(attr[:password])
      session[:uid] = user.id
      redirect_to analysis_list_path and return if user.teacher_side?
      redirect_to main_select_path and return
    else
      flash.now.alert = "ログイン失敗"
      render :new
    end
  end

  def destroy
    redirect_to login_path
  end

  def destroy_player
    session[:lid] = session[:pid] = nil
    redirect_to main_select_path
  end
end

