class AddPenaltyScoresToFixtures < ActiveRecord::Migration[8.0]
  def change
    add_column :fixtures, :home_penalty_score, :integer
    add_column :fixtures, :away_penalty_score, :integer
  end
end
