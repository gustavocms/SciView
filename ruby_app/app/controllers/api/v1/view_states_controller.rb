class Api::V1::ViewStatesController < ApplicationController
  respond_to :json

  def index
    respond_with ViewState.all
  end

  def show
    respond_with view_state
  end

  private

  def view_state
    @view_state ||= ViewState.find(params[:id])
  end
end
