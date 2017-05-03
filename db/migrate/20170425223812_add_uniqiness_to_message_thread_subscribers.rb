class AddUniqinessToMessageThreadSubscribers < ActiveRecord::Migration
  def change
    remove_index :thread_subscriptions, [:thread_id, :user_id]
    execute <<-SQL
    DELETE FROM thread_subscriptions
    WHERE id NOT IN (
      SELECT MIN (id) AS min_id
      FROM thread_subscriptions
      WHERE deleted_at IS NULL
      GROUP BY user_id, thread_id
    )
    SQL
    add_index :thread_subscriptions, [:thread_id, :user_id], unique: true, where: "deleted_at IS NULL"
  end
end
