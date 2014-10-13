class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.references :user
      t.references :view_state
      t.datetime   :observed_at
      t.text       :message

      t.timestamps
    end
  end
end
