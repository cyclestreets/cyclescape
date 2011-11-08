class CreateLibraryDocuments < ActiveRecord::Migration
  def change
    create_table :library_documents do |t|
      t.integer :library_item_id, null: false
      t.string :title, null: false
      t.string :file_uid
      t.string :file_name
      t.integer :file_size
    end
  end
end
