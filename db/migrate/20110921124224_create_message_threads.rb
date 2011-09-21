class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.integer :issue_id
      t.integer :created_by_id, null: false
      t.integer :group_id

      t.string :title, null: false
      t.text :description, null: false
      t.string :privacy, null: false
      t.string :state, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
