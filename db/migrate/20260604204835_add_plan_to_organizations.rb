class AddPlanToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :plan, :integer, default: 0, null: false
  end
end
