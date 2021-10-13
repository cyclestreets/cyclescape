class MigrateUserThreadFavourite < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      INSERT INTO user_thread_favourites (user_id, thread_id, created_at)
      SELECT user_id, thread_id, now()
      FROM user_thread_priorities
      WHERE priority >= 3
      GROUP BY user_id, thread_id
    SQL
  end

  def down
  end
end
