class AddOrganizationTournamentToPredictions < ActiveRecord::Migration[8.0]
  def change
    add_reference :predictions, :organization_tournament, null: true, foreign_key: true
  end
end
