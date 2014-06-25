class AttributesController < ApplicationController
  respond_to :json

  def create
    respond_with Dataset.update_attribute(params[:id],params[:attribute], params[:value])
  end

  def destroy
    respond_with Dataset.remove_attribute(params[:id],params[:attribute])
  end
end