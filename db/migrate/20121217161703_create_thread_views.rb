class CreateThreadViews < ActiveRecord::Migration
  def change
    create_table :thread_views do |t|
      t.integer :user_id, null: false
      t.integer :thread_id, null: false
      t.datetime :viewed_at, null: false
    end
  end
end
