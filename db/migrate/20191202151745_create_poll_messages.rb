class CreatePollMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_messages do |t|
      t.references :thread, index: true, null: false
      t.references :message, index: true, foreign_key: true, null: false
      t.references :created_by, index: true, null: false
      t.text :question, null: false

      t.timestamps
    end

    add_foreign_key :poll_messages, :message_threads, column: :thread_id
    add_foreign_key :poll_messages, :users, column: :created_by_id
  end
end
