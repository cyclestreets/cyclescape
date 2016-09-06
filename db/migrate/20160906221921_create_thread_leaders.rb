class CreateThreadLeaders < ActiveRecord::Migration
  def change
    create_table :thread_leaders do |t|
      t.references :user, index: true, foreign_key: true
      t.references :message_thread, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :thread_leaders, [:user_id, :message_thread_id], unique: true
  end
end
