class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :logo_url
      t.string :external_id

      t.timestamps
    end
    add_index :teams, :external_id, unique: true
  end
end
