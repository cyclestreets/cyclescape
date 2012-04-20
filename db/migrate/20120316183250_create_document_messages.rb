class CreateDocumentMessages < ActiveRecord::Migration
  def change
    create_table :document_messages do |t|
      t.integer :thread_id, null: false
      t.integer :message_id, null: false
      t.integer :created_by_id, null: false
      t.string :title, null: false
      t.string :file_uid
      t.string :file_name
      t.integer :file_size
    end
  end
end
