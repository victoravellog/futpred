class AddGroupNameToFixtures < ActiveRecord::Migration[8.0]
  def change
    add_column :fixtures, :group_name, :string
  end
end
