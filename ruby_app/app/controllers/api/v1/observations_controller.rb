class Api::V1::ObservationsController < ApplicationController
  respond_to :json
  before_filter :authenticate_user!

  def index
    render json: observations
  end

  def show
    render json: observation
  end

  def create
    if new_observation.save
      render json: new_observation.as_json
    else
      render json: new_observation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if observation.destroy
      render json: true
    end
  end

  private

  def observation
    @observation ||= Observation.find(params[:id])
  end

  def observations
    Observation.where({ view_state_id: params[:view_state_id] }.compact)
  end

  def new_observation
    @new_observation ||= view_state.observations.new(observation_params.merge(user_id_params))
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
