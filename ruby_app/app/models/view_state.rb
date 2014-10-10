# This model is designed to be served as a JSON structure through the API.
# columns:
# id (Int)
# user_id (Int)
# charts (Postgres JSON)
#
# The structure follows the UIDataset model in the angular app:
#
# { 
#   id: 0
#   user_id: 1
#   charts: [
#     { 
#       title: 'chart title'
#       channels: [
#         {
#           state: 'expanded'
#           title: 'channel title'
#           series: [
#             { title: "sample_012345", key: { color: 'red', style: 'solid' }}
#           ]
#         }
#       ]
#     }
#   ]
# }
#  
# This is fetched by angular's ViewState resource and built into the appropriate
# objects by SciView.Models.UIDataset.deserialize.
#

require 'securerandom'

class ViewState < ActiveRecord::Base
  has_many :observations

  before_create :set_defaults
  before_save :ensure_chart_uuids

  protected

  def set_defaults
    if charts.blank?
      self.charts = default_charts
    end
  end

  private

  def ensure_chart_uuids
    charts_will_change!
    Array(charts).each do |chart|
      chart["uuid"] ||= SecureRandom.uuid
    end
  end

  def default_charts
    [{ "title" => "Default Chart", "channels" => [default_channel] }]
  end

  def default_channel
    { "title" => "Default Channel", "series" => [] }
  end
end
