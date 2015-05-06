class CreateStreetViewMessages < ActiveRecord::Migration
  def change
    create_table :street_view_messages do |t|
      t.references :message
      t.references :thread
      t.integer :created_by_id
      t.geometry :location, srid: 4326
      t.decimal :heading
      t.decimal :pitch
      t.string :caption

      t.timestamps
    end
    add_index :street_view_messages, :message_id
    add_index :street_view_messages, :thread_id
    add_index :street_view_messages, :location, spatial: true
  end
end
