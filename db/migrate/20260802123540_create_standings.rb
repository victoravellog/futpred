class CreateStandings < ActiveRecord::Migration[8.0]
  def change
    create_table :standings do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.integer :played_games, null: false, default: 0
      t.integer :won, null: false, default: 0
      t.integer :draw, null: false, default: 0
      t.integer :lost, null: false, default: 0
      t.integer :points, null: false, default: 0
      t.integer :goals_for, null: false, default: 0
      t.integer :goals_against, null: false, default: 0
      t.integer :goal_difference, null: false, default: 0

      t.timestamps
    end

    add_index :standings, [ :tournament_id, :team_id ], unique: true
    add_index :standings, [ :tournament_id, :position ]
  end
end
