class RemoveFormatFromVinyls < ActiveRecord::Migration[8.1]
  def change
    remove_column :vinyls, :format, :string
    remove_column :vinyls, :tracks, :json
  end
end
