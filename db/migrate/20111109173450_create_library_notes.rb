class CreateLibraryNotes < ActiveRecord::Migration
  def change
    create_table :library_notes do |t|
      t.integer :library_item_id, null: false
      t.string :title
      t.text :body, null: false
      t.integer :library_document_id
    end
  end
end
