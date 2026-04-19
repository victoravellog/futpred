class AddInviteTokenToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :invite_token, :string
    add_index :organizations, :invite_token, unique: true
  end
end
