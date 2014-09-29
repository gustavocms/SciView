class Api::V1::ObservationsController < ApplicationController
  respond_to :json

  def index
    render json: view_state.observations
  end

  def create
    if observation.save
      render json: observation.as_json
    else
      respond_with observation.errors, status: :unprocessable_entity
    end
  end

  private

  def observation
    @observation ||= view_state.observations.new(observation_params.merge(user_id: current_user.id))
  end

  def view_state
    @view_state ||= ViewState.find(params[:view_state_id])
  end

  def observation_params
    params.require(:observation).permit(:observed_at, :message, :chart_uuid)
  end
end
