class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.string :name
      t.decimal :scoring_multiplier
      t.references :tournament, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
