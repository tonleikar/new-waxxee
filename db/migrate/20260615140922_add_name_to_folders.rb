class AddNameToFolders < ActiveRecord::Migration[8.1]
  def change
    add_column :folders, :name, :string, null: false
  end
end
