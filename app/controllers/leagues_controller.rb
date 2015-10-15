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
    attributes[:card] = read_file file_params[:card]
    attributes[:exec] = read_file file_params[:exec]
    attributes[:header] = read_file file_params[:header]
    attributes[:stock] = read_file file_params[:stock]
    attributes.merge!(rule_params)
    League.create(attributes)
    redirect_to leagues_path
  end

  def edit
  end

  def update
    attributes = league_params
    attributes[:card] = read_file file_params[:card]
    attributes[:exec] = read_file file_params[:exec]
    attributes[:header] = read_file file_params[:header]
    attributes[:stock] = read_file file_params[:stock]
    attributes.merge!(rule_params)
    @league.update(attributes)
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

  def read_file(data)
    return nil if data.nil?
    data.read.force_encoding('utf-8')
  end

  def league_params
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score)
  end

  def file_params
    return {} if params[:file].nil?
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

