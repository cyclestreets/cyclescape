class CreateLibraryItems < ActiveRecord::Migration
  def change
    create_table :library_items do |t|
      t.integer :component_id
      t.string :component_type
      t.integer :created_by_id, null: false
      t.spatial :location, limit: {srid: 4326, type: "geometry"}
      t.datetime :created_at, null: false
      t.datetime :updated_at
      t.datetime :deleted_at
    end
  end
end
