class CreateTournaments < ActiveRecord::Migration[8.0]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.string :external_id
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
