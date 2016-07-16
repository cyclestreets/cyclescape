class AddUrlToLibraryNotes < ActiveRecord::Migration
  def change
    add_column :library_notes, :url, :string
  end
end
