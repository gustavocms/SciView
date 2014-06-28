class TagsController < ApplicationController
  respond_to :json

  def create
    render json: Dataset.add_tag(params[:dataset_id],params[:tag])
  end

  def destroy
    render json: Dataset.remove_tag(params[:dataset_id],params[:id])
  end
end
