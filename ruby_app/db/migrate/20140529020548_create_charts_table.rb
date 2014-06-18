class CreateChartsTable < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    create_table :charts do |t|
      t.references :user, index: true
      t.string :name
      t.hstore :series
    end
  end
end
