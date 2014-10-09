class CreateTdmsFiles < ActiveRecord::Migration
  def change
    create_table :tdms_files do |t|
      t.references :user, index: true
      t.string :filepath

      t.timestamps
    end
  end
end
