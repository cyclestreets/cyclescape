class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :created_by_id, null: false
      t.integer :thread_id, null: false
      t.text :body, null: false

      t.integer :component_id
      t.string :component_type

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :deleted_at
    end
  end
end
