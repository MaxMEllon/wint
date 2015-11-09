class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    begin
      Submit.create(submit_params.merge(player_id: session[:pid]))
    rescue
      @submit = Submit.new
      @submit.errors.messages[:data_dir] = ['入力してください']
      @submit.comment = submit_params[:comment]
      render :new and return
    end
    render 'shared/reload'
  end

  private
  def submit_params
    params.require(:submit).permit(:data_dir, :comment)
  end
end

