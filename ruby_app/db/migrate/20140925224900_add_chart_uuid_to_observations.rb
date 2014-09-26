class AddChartUuidToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :chart_uuid, :string, index: true
  end
end
