class CreatePredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :fixture, null: false, foreign_key: true
      t.integer :predicted_home_score
      t.integer :predicted_away_score
      t.integer :points_earned

      t.timestamps

      t.index [ :user_id, :fixture_id ], unique: true
    end
  end
end
