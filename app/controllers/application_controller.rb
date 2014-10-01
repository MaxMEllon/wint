class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def current_user
    @current_user = User.where(id: session[:uid]).first if session[:uid]
  end

  def current_player
    @current_player = Player.where(id: session[:pid]).first if session[:pid]
  end
end

