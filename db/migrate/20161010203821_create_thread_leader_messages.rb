class CreateThreadLeaderMessages < ActiveRecord::Migration
  def change
    drop_table :thread_leaders

    create_table :thread_leader_messages do |t|
      t.references :message, index: true, foreign_key: true
      t.references :thread
      t.integer :unleading_id
      t.integer :created_by_id
      t.boolean :active, default: true, null: false
      t.text :description
      t.timestamps null: false
    end

    add_index :thread_leader_messages, :thread_id
    add_foreign_key :thread_leader_messages, :message_threads, column: :thread_id

    add_index :thread_leader_messages, :unleading_id
    add_foreign_key :thread_leader_messages, :thread_leader_messages, column: :unleading_id
  end
end
