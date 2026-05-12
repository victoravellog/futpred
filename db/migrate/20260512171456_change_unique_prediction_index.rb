class ChangeUniquePredictionIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :predictions, [:user_id, :fixture_id]
    add_index :predictions, [:user_id, :fixture_id, :organization_tournament_id],
              unique: true, name: "idx_predictions_user_fixture_org_tournament"
  end
end
