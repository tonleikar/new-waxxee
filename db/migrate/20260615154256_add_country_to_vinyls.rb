class AddCountryToVinyls < ActiveRecord::Migration[8.1]
  def change
    add_column :vinyls, :country, :string
  end
end
