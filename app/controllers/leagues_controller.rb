class LeaguesController < ApplicationController
  before_action :get_league, only: [:edit, :update, :toggle, :toggle_analy]

  def list
    @leagues = League.all
  end

  def new
    @league = League.new
    @league.start_at = @league.end_at = Time.new.strftime("%Y.%m.%d 00:00")
  end

  def create
    @league = League.new(league_params)
    @league.data_dir = "dummy"
    render :new and return unless @league.save

    @league.data_dir = @league.mkdir
    @league.save!
    render 'shared/reload'
  end

  def edit
  end

  def update
    render :edit and return unless @league.update(league_params)
    render "shared/reload"
  end

  def toggle
    @league.update(is_active: !@league.is_active)
    redirect_to leagues_path
  end

  def toggle_analy
    @league.update(is_analy: !@league.is_analy)
    redirect_to leagues_path
  end

  private

  def league_params
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score, :change, :take, :try)
  end

  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

