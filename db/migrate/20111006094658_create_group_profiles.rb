class CreateGroupProfiles < ActiveRecord::Migration
  def change
    create_table :group_profiles do |t|
      t.integer :group_id, null: false

      t.text :description
      t.geometry :location, srid: 4326

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
