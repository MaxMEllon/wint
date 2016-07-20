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
    @league.data_dir = @league.rule_file = "dummy" if full_rule_params?
    render :new and return unless @league.save

    @league.data_dir = @league.mkdir
    @league.rule_file = @league.set_rule(rule_params)
    @league.save!
    render 'shared/reload'
  end

  def edit
  end

  def update
    render :edit and return unless @league.update(league_params)
    @league.set_rule(rule_params) if full_rule_params?
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
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score)
  end

  def rule_params
    params.require(:rule).permit(:take, :change, :try)
  end

  def full_rule_params?
    rule = params[:rule]
    return false if rule.nil?
    [rule[:take], rule[:change], rule[:try]].all? {|r| r.present?}
  end

  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

