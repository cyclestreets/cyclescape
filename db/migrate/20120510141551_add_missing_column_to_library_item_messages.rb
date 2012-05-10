class AddMissingColumnToLibraryItemMessages < ActiveRecord::Migration
  def change
    add_column :library_item_messages, :created_by_id, :integer
  end
end
