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
    attributes = league_params
    attributes[:card] = file_params[:card].read.force_encoding('utf-8')
    attributes[:exec] = file_params[:exec].read.force_encoding('utf-8')
    attributes[:header] = file_params[:header].read.force_encoding('utf-8')
    attributes[:stock] = file_params[:stock].read.force_encoding('utf-8')
    attributes[:rule_json] = ModelHelper.encode_json rule_params
    League.create(attributes)
    redirect_to leagues_path
  end

  def edit
  end

  def update
    render :edit and return unless @league.update(league_params)
    @league.set_data(file_params) if file_params.present?
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

  def file_params
    return nil if params[:file].nil?
    params.require(:file).permit(:stock, :header, :exec, :card)
  end

  def rule_params
    params.require(:rule).permit(:take, :change, :try)
  end

  def full_file_params?
    file = params[:file]
    return false if file.nil?
    file[:stock].present? && file[:header].present? && file[:exec].present? && file[:card].present?
    [file[:stock], file[:header], file[:exec], file[:card]].all? {|f| f.present?}
  end

  def full_rule_params?
    rule = params[:rule]
    return false if rule.nil?
    [rule[:take], rule[:change], rule[:try]].all? {|r| r.present?}
  end

  def full_params?
    full_file_params? && full_rule_params?
  end

  def get_league
    @league = League.where(id: params[:lid]).first
  end
end

