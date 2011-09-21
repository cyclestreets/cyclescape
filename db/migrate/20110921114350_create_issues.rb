class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :created_by_id, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :deleted_at
    end
  end
end
