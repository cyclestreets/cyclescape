class CreateActionMessages < ActiveRecord::Migration
  def change
    create_table :action_messages do |t|
      t.integer :completing_message_id
      t.string :completing_message_type
      t.references :thread, index: true, null: false
      t.references :message, index: true, foreign_key: true, null: false
      t.references :created_by, index: true, null: false
      t.string :description, null: false

      t.timestamps null: false
    end

    add_index :action_messages, :completing_message_id
    add_foreign_key :action_messages, :users, column: :created_by_id
    add_foreign_key :action_messages, :message_threads,  column: :thread_id
  end
end
