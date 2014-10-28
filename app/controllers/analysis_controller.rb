class AnalysisController < ApplicationController
  def list
    @leagues = League.active
  end

  def league
    @league = League.where(id: params[:lid]).first
  end
end

