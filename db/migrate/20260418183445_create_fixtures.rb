class CreateFixtures < ActiveRecord::Migration[8.0]
  def change
    create_table :fixtures do |t|
      t.references :round, null: false, foreign_key: true
      t.references :home_team, null: false, foreign_key: { to_table: :teams }
      t.references :away_team, null: false, foreign_key: { to_table: :teams }
      t.datetime :kickoff_at
      t.integer :home_score
      t.integer :away_score
      t.integer :status
      t.string :external_id

      t.timestamps
    end
  end
end
