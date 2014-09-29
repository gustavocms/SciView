class Api::V1::ViewStatesController < ApplicationController
  respond_to :json

  def index
    render json: ViewState.all
  end

  def show
    render json: view_state
  end

  def create
    view_state = ViewState.new.tap do |vs|
      vs.user_id = current_user.id if current_user
      vs.title = "New Dataset"
      vs.charts = []
    end

    if view_state.save
      respond_with view_state, location: api_v1_view_state_url(view_state)
    end
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
        respond_with view_state.errors.as_json
      end
    end
  end

  def destroy
    respond_with true if view_state.destroy
  end

  private

  def view_state
    @view_state ||= ViewState.find(params[:id])
  end

  def view_state_params
    params.permit(:title, :charts)
  end
end
