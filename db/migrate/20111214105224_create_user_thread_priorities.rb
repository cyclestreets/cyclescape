class CreateUserThreadPriorities < ActiveRecord::Migration
  def change
    create_table :user_thread_priorities do |t|
      t.integer :user_id, null: false
      t.integer :thread_id, null: false
      t.integer :priority, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
