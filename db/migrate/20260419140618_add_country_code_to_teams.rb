class AddCountryCodeToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :country_code, :string
  end
end
