class CreatePhotoMessages < ActiveRecord::Migration
  def change
    create_table :photo_messages do |t|
      t.integer :thread_id, null: false
      t.integer :message_id, null: false
      t.integer :created_by_id, null: false
      t.string :photo_uid, null: false
      t.string :caption
      t.text :description
      t.datetime :created_at, null: false
    end
  end
end
