class CreateLinkMessages < ActiveRecord::Migration
  def change
    create_table :link_messages do |t|
      t.integer :thread_id, null: false
      t.integer :message_id, null: false
      t.integer :created_by_id, null: false
      t.text :url, null: false
      t.string :title
      t.text :description
      t.datetime :created_at
    end
  end
end
