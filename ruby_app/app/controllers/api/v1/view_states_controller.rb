class Api::V1::ViewStatesController < ApplicationController
  respond_to :json

  def index
    respond_with ViewState.all
  end

  def show
    respond_with view_state
  end

  def create
    puts params.inspect
  end

  def update
    ViewState.find(params[:id]).tap do |view_state|
      # NOTE: Postgres' hstore columns behave somewhat unexpectedly with regards to
      # ActiveRecord's dirty attribute checking. This explicit update is the easiest way to workaround.
      view_state.charts_will_change!
      view_state.charts = params[:charts]
      view_state.title  = params[:title]
      if view_state.save!
        respond_with true
      else
        respon_with view_state.errors.as_json
      end
    end
  end

  private

  def view_state
    @view_state ||= ViewState.find(params[:id])
  end

  def view_state_params
    params.permit(:title, :charts)
  end
end
