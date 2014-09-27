class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    @submit = Submit.new(submit_params.merge(player_id: params[:pid], number: 0))
    unless @submit.data_dir.blank?
      source = @submit.data_dir.read.force_encoding("utf-8")
      @submit.data_dir = "dummy"
    end
    render :new and return unless @submit.save

    @submit.number = @submit.get_number
    @submit.data_dir = @submit.mkdir
    @submit.set_data(source)



    @submit.save!
    redirect_to mains_mypage
  end

  private
  def submit_params
    params.require(:submit).permit(:data_dir, :comment)
  end
end

