class LeaguesController < ApplicationController
  before_action :get_league, only: [:edit, :update, :toggle]

  def list
    @leagues = League.all
  end

  def new
    @league = League.new
    @league.start_at = @league.end_at = Time.new
  end

  def create
    @league = League.new(league_params)
    #@league.src_path = @league.set_src(file_params)
    #@league.rule_file = @league.set_rule(rule_params)
    render :new and return unless @league.save
    render template: "shared/reload"
  end

  def edit
  end

  def update
    render :edit and return unless @league.update(league_params)
    render template: "shared/reload"
  end

  def toggle
    @league.is_active = !@league.is_active
    @league.save
    redirect_to leagues_path
  end

  private
  def league_params
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score, :is_analy)
  end

  def file_params
    params.require(:file).permit(:stock, :header, :exec, :card)
  end

  def rule_params
    params.require(:rule).permit(:take, :change, :try)
  end

  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

