class CreateViewStates < ActiveRecord::Migration
  def change
    create_table :view_states do |t|
      t.references :user
      t.json :state

      t.timestamps
    end
  end
end
