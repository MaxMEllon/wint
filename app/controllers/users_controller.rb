class UsersController < ApplicationController
  def list
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def edit
    @user = User.where(id: params[:uid]).first
  end

  def update
    render text: params
  end

  private
  def user_params
    params.require(:user).permit(:snum, :name, :depart, :entrance, :category, :password, :password_confirmation)
  end
end

