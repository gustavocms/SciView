class Api::V1::SeriesController < ApplicationController
  respond_to :json

  def index
    render json: Dataset.all(params)
  end

  def show
    render json: series_metadata
  end

  def update
    render json: Dataset.update_series(series_params)
  end

  private

  # The `@attributes` ivar from TempoDB is a basic ruby hash,
  # but a peculiarity  in angular-data wants them to be an array
  # of key-value objects. 
  #
  # This pair of methods handles the conversion to and from
  # these disparate formats.
  def series_metadata
    Dataset.series_metadata(params[:id]).as_json.tap do |json|
      json["attributes"] = json["attributes"].map {|k,v| { "key" => k, "value" => v }}
    end
  end

  def series_params
    params[:series].dup.tap do |hash|
      puts hash["attributes"].inspect
      hash["attributes"] = Hash[hash["attributes"].map(&:values)]
      puts hash["attributes"].inspect
    end
  end
end
