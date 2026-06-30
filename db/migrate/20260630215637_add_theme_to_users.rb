class AddThemeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme, :string, default: "dark", null: false
  end
end
