class ChangeGenreToArrayInVinyls < ActiveRecord::Migration[7.0]
  def up
    # Splits by ' / ' (ignoring extra spaces around it) and converts to an array
    change_column :vinyls, :genre, :string, array: true, default: [], using: "regexp_split_to_array(genre, '\s*/\s*')"
  end

  def down
    # Reverts back by joining the array elements with ' / '
    change_column :vinyls, :genre, :string, array: false, default: nil, using: "array_to_string(genre, ' / ')"
  end
end
