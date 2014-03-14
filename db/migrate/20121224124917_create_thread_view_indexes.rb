class CreateThreadViewIndexes < ActiveRecord::Migration
  def change
    add_index(:thread_views, [:user_id, :thread_id],  unique: true )
    add_index(:thread_views, :user_id)
  end
end
