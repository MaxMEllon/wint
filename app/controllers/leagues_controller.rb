class LeaguesController < ApplicationController
  def list
    @leagues = League.all
  end

  def new
    @league = League.new
    @league.start_at = @league.end_at = Time.new.strftime('%Y.%m.%d 00:00')
  end

  def create
    attributes = league_params
    attributes.merge!(
      card: read_file(file_params[:card]),
      exec: read_file(file_params[:exec]),
      header: read_file(file_params[:header]),
      stock: read_file(file_params[:stock])
    )
    attributes.merge!(rule_params)
    League.create(attributes)
    redirect_to leagues_path
  end

  def edit
    @league = league
  end

  def update
    attributes = league_params
    attributes.merge!(
      card: read_file(file_params[:card]),
      exec: read_file(file_params[:exec]),
      header: read_file(file_params[:header]),
      stock: read_file(file_params[:stock])
    )
    attributes.merge!(rule_params)
    league.update(attributes)
    render 'shared/reload'
  end

  def toggle
    league.update(is_active: !league.is_active)
    redirect_to leagues_path
  end

  def toggle_analy
    league.update(is_analy: !league.is_analy)
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

  def league
    @league ||= League.find(params[:lid])
  end
end

