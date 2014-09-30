class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    @submit = Submit.new(submit_params.merge(player_id: params[:pid]))
    unless @submit.data_dir.blank?
      source = @submit.data_dir.read.force_encoding("utf-8")
      @submit.data_dir = "dummy"
    end
    @submit.number = @submit.get_number
    render :new and return unless @submit.save

    @submit.data_dir = @submit.mkdir
    @submit.set_data(source)
    @submit.status = @submit.get_status
    @submit.save!
    if @submit.exec_success?
      strategy = Strategy.create(@submit)
      strategy.submit.player.update(submit_id: @submit.id) if strategy.best?
    end

    redirect_to mains_mypage_path
  end

  private
  def submit_params
    params.require(:submit).permit(:data_dir, :comment)
  end
end

