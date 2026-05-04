class CreateOrganizationTournaments < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_tournaments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end

    add_index :organization_tournaments, [ :organization_id, :tournament_id ], unique: true, name: "idx_org_tournaments_unique"
  end
end
