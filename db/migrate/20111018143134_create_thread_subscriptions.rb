class CreateThreadSubscriptions < ActiveRecord::Migration
  def change
    create_table :thread_subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :thread_id, null: false
      t.datetime :created_at, null: false
      t.datetime :deleted_at
    end
  end
end
