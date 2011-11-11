class CreateDeadlineMessages < ActiveRecord::Migration
  def change
    create_table :deadline_messages do |t|
      t.integer :thread_id, null: false
      t.integer :message_id, null: false
      t.integer :created_by_id, null: false

      t.datetime :deadline, null: false
      t.string :title, null: false
      t.datetime :created_at
      t.datetime :invalidated_at
      t.integer :invalidated_by_id
    end
  end
end
