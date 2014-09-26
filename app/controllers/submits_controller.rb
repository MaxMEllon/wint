class SubmitsController < ApplicationController
  def new
    @submit = Submit.new
  end

  def create
    @submit = Submit.new(submit_params)
    render :new and return unless @submit.save
    #@submit.player_id = params[:pid]
    #@submit.number = @submit.get_number
    #@submit.mkdir if @submit.number == 1
    #@submit.src_file = @submit.set_src
    #render text: @submit.inspect
    render template: "shared/reload"
  end

  private
  def submit_params
    params.require(:submit).permit(:src_file, :comment)
  end
end

