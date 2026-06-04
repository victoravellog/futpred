class AddLocaleToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :locale, :string, default: "es", null: false
  end
end
