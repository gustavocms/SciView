# This controller serves json to the SciView angular app. It is designed to replicate the functionality
# of the existing DatasetsController (its parent class) with additional layers wrapped around the response
# to conform to the expected front-end format.
#
# In this early stage, the response from `multiple` is as follows:
class Api::V1::DatasetsController < ::DatasetsController
  respond_to :json

  def multiple
    respond_with_series do |data|
      {
        id: '0',
        title: 'TEMP DATASET',
        batch: [
          {
            title: 'Default Batch', chart: 'assets/graph_1.svg', channel: [
              { title: 'random_sensor', category: 'api_test', key: { color: 'red', style: 'solid' }}
            ]
          }
        ]
      }
    end
  end
end
