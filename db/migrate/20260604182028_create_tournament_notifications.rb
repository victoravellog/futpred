class CreateTournamentNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.string :channel, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end

    add_index :tournament_notifications,
              [ :user_id, :tournament_id, :notification_type, :channel ],
              unique: true,
              name: "idx_tournament_notifications_unique"
  end
end
