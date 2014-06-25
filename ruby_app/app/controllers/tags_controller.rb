class TagsController < ApplicationController
  respond_to :json

  def create
    respond_with Dataset.add_tag(params[:dataset_id],params[:tag])
  end

  def destroy
    respond_with Dataset.remove_tag(params[:dataset_id],params[:tag])
  end
end
