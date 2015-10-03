class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    submit = Submit.create(submit_params.merge(player_id: session[:pid]))
    HardWorker.perform_async(submit.id)
    render 'shared/reload'
  end

  private
  def submit_params
    params.require(:submit).permit(:data_dir, :comment)
  end
end

