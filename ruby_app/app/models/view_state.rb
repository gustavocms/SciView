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
class ViewState < ActiveRecord::Base
  has_many :observations
end
