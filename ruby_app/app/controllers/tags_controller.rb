class TagsController < ApplicationController
  respond_to :json

  def create
    respond_with Dataset.add_tag(params[:dataset_id],params[:tag]), :location => root_url
  end

  def destroy
    respond_with Dataset.remove_tag(params[:dataset_id],params[:id])
  end
end
