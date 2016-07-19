class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    @submit = Submit.new(submit_params.merge(player_id: session[:pid]))
    unless @submit.data_dir.blank?
      source = submit_params[:data_dir].read.force_encoding("utf-8")
      if @submit.size_over? || submit_params[:data_dir].original_filename.split(".").last != "c"
        @submit.data_dir = nil
      else
        @submit.data_dir = "dummy"
      end
    end
    @submit.number = @submit.get_number
    render :new and return unless @submit.save

    @submit.update(data_dir: @submit.mkdir)
    @submit.set_data(source)
    HardWorker.perform_async(@submit.id)
    redirect_to main_mypage_path
  end

  private
  def submit_params
    params.require(:submit).permit(:data_dir, :comment)
  end
end

