class RemoveNameFromFolders < ActiveRecord::Migration[8.1]
  def change
    remove_column :folders, :name, :string
  end
end
