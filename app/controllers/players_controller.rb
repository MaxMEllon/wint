class PlayersController < ApplicationController
  def list
    @players = Player.all
  end

  def select
    @users = User.all
  end

  def new_many
    user_ids = []
    user_ids = params.require(:user_id).keys if params[:user_id].present?
    @users = User.where(id: user_ids)
    @league = League.where(id: params[:league_id]).first
  end

  def create_many
    params.require(:player).each do |user_id, value|
      Player.create(league_id: params[:league_id], user_id: user_id,
                    name: value[:name], role: value[:role])
    end
    redirect_to players_path
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    render :new && return unless @player.save
    redirect_to players_path
  end

  def edit
    @player = Player.find(params[:pid])
  end

  def update
    @player = Player.find(params[:pid])
    render :edit && return unless @player.update(player_params)
    render 'shared/reload'
  end

  def toggle
    @player = Player.find(params[:pid])
    @player.update(is_active: !@player.is_active)
    redirect_to players_path
  end

  private

  def player_params
    params.require(:player).permit(:user_id, :league_id, :name, :role)
  end
end

