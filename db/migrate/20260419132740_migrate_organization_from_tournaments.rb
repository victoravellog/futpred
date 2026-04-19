class MigrateOrganizationFromTournaments < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      INSERT INTO organization_tournaments (organization_id, tournament_id, created_at, updated_at)
      SELECT organization_id, id, NOW(), NOW()
      FROM tournaments
      WHERE organization_id IS NOT NULL
      ON CONFLICT DO NOTHING
    SQL

    execute <<-SQL
      UPDATE predictions
      SET organization_tournament_id = ot.id
      FROM organization_tournaments ot
      JOIN tournaments t ON t.id = ot.tournament_id
      JOIN rounds r ON r.tournament_id = t.id
      JOIN fixtures f ON f.round_id = r.id
      WHERE predictions.fixture_id = f.id
        AND predictions.organization_tournament_id IS NULL
    SQL

    remove_foreign_key :tournaments, :organizations
    remove_index :tournaments, :organization_id
    remove_column :tournaments, :organization_id
  end

  def down
    add_reference :tournaments, :organization, foreign_key: true

    execute <<-SQL
      UPDATE tournaments
      SET organization_id = ot.organization_id
      FROM organization_tournaments ot
      WHERE tournaments.id = ot.tournament_id
    SQL
  end
end
