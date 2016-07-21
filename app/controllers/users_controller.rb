class UsersController < ApplicationController
  before_action :get_user, only: [:edit, :update, :edit_password, :update_password, :toggle]

  def list
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = @user.password_confirmation = @user.snum.split("").reverse.join
    render :new and return unless @user.save
    render template: "shared/reload"
  end

  def edit
  end

  def update
    render :edit and return unless @user.update(user_params)
    render template: "shared/reload"
  end

  def edit_password
  end

  def update_password
    render :edit_password and return unless @user.update(user_params)
    render template: "shared/reload"
  end

  def toggle
    @user.is_active = !@user.is_active
    @user.save
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(:snum, :name, :category, :password, :password_confirmation)
  end

  def get_user
    @user = User.where(id: params[:uid]).first
  end
end

