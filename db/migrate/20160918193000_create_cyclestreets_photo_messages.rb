class CreateCyclestreetsPhotoMessages < ActiveRecord::Migration
  def change
    create_table :cyclestreets_photo_messages do |t|
      t.integer :cyclestreets_id
      t.json :icon_properties
      t.string :photo_uid, null: false
      t.references :thread, index: true, references: :message_threads, null: false
      t.references :message, index: true, foreign_key: true, null: false
      t.references :created_by, index: true, references: :users, null: false
      t.text :caption
      t.geometry :location, srid: 4326, null: false
      t.timestamps null: false
    end
    add_foreign_key :cyclestreets_photo_messages, :message_threads,  column: :thread_id
    add_foreign_key :cyclestreets_photo_messages, :users,  column: :created_by_id
  end
end
