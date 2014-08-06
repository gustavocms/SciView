class CreateViewStates < ActiveRecord::Migration
  def change
    create_table :view_states do |t|
      t.references :user
      t.string :title
      t.json :charts

      t.timestamps
    end
  end
end
