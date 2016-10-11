class LeaguesController < ApplicationController
  def list
    @leagues = League.all
  end

  def new
    @league = League.new
    @league.start_at = @league.end_at = Time.new.strftime('%Y.%m.%d 00:00')
  end

  def create
    @league = League.create(league_params)
    render :new && return if @league.id.nil?
    render 'shared/reload'
  end

  def edit
    @league = League.find(params[:lid])
  end

  def update
    @league = League.find(params[:lid])
    render :edit && return unless @league.update(league_params)
    render 'shared/reload'
  end

  def toggle
    @league = League.find(params[:lid])
    @league.update(is_active: !@league.is_active)
    redirect_to leagues_path
  end

  def toggle_analy
    @league = League.find(params[:lid])
    @league.update(is_analy: !@league.is_analy)
    redirect_to leagues_path
  end

  private

  def league_params
    params.require(:league).permit(:name, :start_at, :end_at, :limit_score, :change, :take, :try, :weight)
  end
end

