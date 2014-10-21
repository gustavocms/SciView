class Api::V1::SeriesController < ApplicationController
  respond_to :json
  before_filter :authenticate_user!

  def index
    render json: Dataset.all(params)
  end

  def show
    render json: series_metadata
  end

  def update
    render json: update_series_metadata
  end

  private

  # The `@attributes` ivar from TempoDB is a basic ruby hash,
  # but a peculiarity  in angular-data wants them to be an array
  # of key-value objects. 
  #
  # This quatrain of methods handles the conversion to and from
  # these disparate formats.
  def series_metadata
    attributes_to_array(Dataset.series_metadata(params[:id]))
  end

  def update_series_metadata
    attributes_to_array(Dataset.update_series(series_params))
  end

  def attributes_to_array(obj)
    obj.as_json.tap do |json|
      json["attributes"] = json["attributes"].map {|k,v| { "key" => k, "value" => v }}
    end
  end

  def series_params
    params[:series].dup.tap do |hash|
      values = Array(hash["attributes"]).map(&:values).to_h
      hash["attributes"] = values.to_h
    end
  end
end
