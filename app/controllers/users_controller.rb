class UsersController < ApplicationController
  def list
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
  end

  def edit
  end

  def update
  end
end

