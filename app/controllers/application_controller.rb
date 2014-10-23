class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :current_user, unless: :session_controller?
  before_action :current_player, unless: :session_controller?
  before_action :render_404, if: :admin_area?

  def current_user
    @current_user = User.where(id: session[:uid]).first if session[:uid]
  end

  def current_player
    @current_player = Player.where(id: session[:pid]).first if session[:pid]
  end

  def render_404
    render file: "#{Rails.root}/public/404", status: 404, layout: false
  end

  private
  def session_controller?
    controller_name == "sessions"
  end

  def admin_area?
    return false if @current_user && @current_user.admin?
    %w(users leagues players).any? {|c| controller_name == c}
  end
end

