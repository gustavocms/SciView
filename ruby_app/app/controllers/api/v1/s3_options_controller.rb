class Api::V1::S3OptionsController < ApplicationController

  include S3OptionsHelper

  def show
    render json: s3_policy 
  end

end
