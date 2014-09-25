class PlayersController < ApplicationController
  before_action :get_player, only: [:edit, :update, :toggle]

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
      Player.create(league_id: params[:league_id], user_id: user_id, name: value[:name], role: value[:role], submit_id: 0)
    end
    redirect_to players_path
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    render :new and return unless @player.save
    redirect_to players_path
  end

  def edit
  end

  def update
    render :edit and return unless @player.update(player_params)
    render "shared/reload"
  end

  def toggle
    @player.is_active = !@player.is_active
    @player.save
    redirect_to players_path
  end

  private
  def player_params
    params.require(:player).permit(:user_id, :league_id, :name, :role)
  end

  def get_player
    @player = Player.where(id: params[:pid]).first
  end
end
