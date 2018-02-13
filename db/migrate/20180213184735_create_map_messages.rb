class CreateMapMessages < ActiveRecord::Migration
  def change
    create_table :map_messages do |t|
      t.geometry :location, srid: 4326, null: false
      t.references :thread, index: true, null: false
      t.references :message, index: true, foreign_key: true, null: false
      t.references :created_by, index: true, null: false
      t.text :caption

      t.timestamps null: false
    end
    add_foreign_key :map_messages, :message_threads, column: :thread_id
    add_foreign_key :map_messages, :users, column: :created_by_id

    add_index :thread_leader_messages, :created_by_id
    add_foreign_key :thread_leader_messages, :users, column: :created_by_id
  end
end
