class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id, null: false
      t.geometry :location, srid: 4326

      t.integer :category_id, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
