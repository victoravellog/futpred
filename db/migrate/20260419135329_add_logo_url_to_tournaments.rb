class AddLogoUrlToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :logo_url, :string
  end
end
