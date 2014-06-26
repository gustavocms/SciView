class AttributesController < ApplicationController
  respond_to :json

  def create
    render json: Dataset.update_attribute(params[:dataset_id], params[:attribute], params[:value])
  end

  def destroy
    render json: Dataset.remove_attribute(params[:dataset_id], params[:id])
  end
end
