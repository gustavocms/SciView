class AttributesController < ApplicationController
  respond_to :json

  def create
    respond_with Dataset.update_attribute(params[:dataset_id], params[:attribute], params[:value]), :location => root_url
  end

  def destroy
    respond_with Dataset.remove_attribute(params[:dataset_id], params[:id])
  end
end
