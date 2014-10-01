class Api::V1::ObservationsController < ApplicationController
  respond_to :json

  def index
    render json: view_state.observations
  end

  def create
    if observation.save
      render json: observation.as_json
    else
      render json: observation.errors, status: :unprocessable_entity
    end
  end

  private

  def observation
    puts "observation_params #{observation_params.inspect}"
    @observation ||= view_state.observations.new(observation_params.merge(user_id_params))
  end

  def view_state
    @view_state ||= ViewState.find(params[:view_state_id])
  end

  def observation_params
    params.require(:observation).permit(:observed_at, :message, :chart_uuid, :view_state_id)
  end

  def user_id_params
    {}.tap {|hash| hash[:user_id] = current_user.id if current_user }
  end
end
