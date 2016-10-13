class UsersController < ApplicationController
  def list
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = @user.password_confirmation = @user.snum.reverse
    render :new && return unless @user.save
    render template: 'shared/reload'
  end

  def new_many
  end

  def create_many
    users = params[:snum_and_name].split(/\r\n|\n/).map { |user| user.split(',') }
    users.each do |snum, name|
      user = User.new(snum: snum, name: name, category: User::CATEGORY_STUDENT)
      user.password = user.password_confirmation = user.snum.reverse
      user.save
    end
    render template: 'shared/reload'
  end

  def edit
    @user = User.find(params[:uid])
  end

  def update
    @user = User.find(params[:uid])
    render :edit && return unless @user.update(user_params)
    render template: 'shared/reload'
  end

  def edit_password
    @user = User.find(params[:uid])
  end

  def update_password
    @user = User.find(params[:uid])
    render :edit_password && return unless @user.update(user_params)
    render template: 'shared/reload'
  end

  def toggle
    @user = User.find(params[:uid])
    @user.update(is_active: !@user.is_active)
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:snum, :name, :category, :password, :password_confirmation)
  end
end

