class CreateLocationCategories < ActiveRecord::Migration
  def change
    create_table :location_categories do |t|
      t.string :name, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
