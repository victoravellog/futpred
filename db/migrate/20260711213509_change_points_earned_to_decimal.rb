class ChangePointsEarnedToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :predictions, :points_earned, :decimal, precision: 5, scale: 2
  end
end
