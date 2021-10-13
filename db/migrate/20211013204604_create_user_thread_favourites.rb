class CreateUserThreadFavourites < ActiveRecord::Migration[5.2]
  def change
    create_table :user_thread_favourites do |t|
      t.references :user, foreign_key: true, null: false
      t.references :thread, index: false, foreign_key: { to_table: :message_threads } , null: false
      t.datetime :created_at, null: false
    end

    add_index :user_thread_favourites, [:thread_id, :user_id], unique: true
  end
end
