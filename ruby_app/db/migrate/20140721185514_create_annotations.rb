class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.string :series_key, index: true
      t.datetime :timestamp
      t.text :message

      t.timestamps
    end
  end
end
