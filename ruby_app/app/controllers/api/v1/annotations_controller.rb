class Api::V1::AnnotationsController < ApplicationController
  respond_to :json
  def index
    respond_with Annotation.where(series_key: series_key)
  end

  private

  def series_key
    params[:series_id]
  end
end
