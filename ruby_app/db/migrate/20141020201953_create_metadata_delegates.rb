class CreateMetadataDelegates < ActiveRecord::Migration
  def change
    create_table :metadata_delegates do |t|
      t.string :key
      t.text :meta_tags
      t.text :meta_attributes
      t.timestamps
    end
  end
end
