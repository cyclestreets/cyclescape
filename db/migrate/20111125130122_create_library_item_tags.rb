class CreateLibraryItemTags < ActiveRecord::Migration
  def change
    create_table :library_item_tags, id: false do |t|
      t.integer :library_item_id, null: false
      t.integer :tag_id, null: false
    end

    add_index :library_item_tags, [:library_item_id, :tag_id], unique: true
  end
end
