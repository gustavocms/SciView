class Observation < ActiveRecord::Base
  belongs_to :user
  belongs_to :view_state # Attached to a specific "DataSet" in the UI

  # Other Fields:
  # observed_at (DateTime)
  # message     (Text)
end
