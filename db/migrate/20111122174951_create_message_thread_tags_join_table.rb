class CreateMessageThreadTagsJoinTable < ActiveRecord::Migration
  def up
    create_table :message_thread_tags, id: false do |t|
      t.integer :thread_id, null: false
      t.integer :tag_id, null: false
    end

    add_index :message_thread_tags, [:thread_id, :tag_id], unique: true
  end

  def down
    drop_table :message_thread_tags
  end
end
