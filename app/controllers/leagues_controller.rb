class LeaguesController < ApplicationController
  before_action :get_league, only: [:edit, :update, :toggle, :toggle_analy]

  def list
    @leagues = League.all
  end

  def new
    @league = League.new
    @league.start_at = @league.end_at = Time.new.strftime("%Y-%m-%d 00:00:00")
  end

  def create
    @league = League.new(league_params)
    League.mkdir
    @league.src_dir = @league.set_src(file_params)
    @league.rule_file = @league.set_rule(rule_params)
    unless @league.save
      League.rmdir
      render :new and return
    end
    redirect_to leagues_path
  end

  def edit
  end

  def update
    @league.src_dir = @league.set_src(file_params)
    @league.rule_file = @league.set_rule(rule_params)
    render :edit and return unless @league.update(league_params)
    render template: "shared/reload"
  end

  def toggle
    @league.is_active = !@league.is_active
    @league.save
    redirect_to leagues_path
  end

  def toggle_analy
    @league.is_analy = !@league.is_analy
    @league.save
    redirect_to leagues_path
  end

  private
  def league_params
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score, :is_analy)
  end

  def file_params
    return nil if params[:file].nil?
    params.require(:file).permit(:stock, :header, :exec, :card)
  end

  def rule_params
    params.require(:rule).permit(:take, :change, :try)
  end

  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

