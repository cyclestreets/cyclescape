class CreateLibraryItemMessages < ActiveRecord::Migration
  def change
    create_table :library_item_messages do |t|
      t.integer :thread_id, null: false
      t.integer :message_id, null: false
      t.integer :library_item_id, null: false
    end
  end
end
