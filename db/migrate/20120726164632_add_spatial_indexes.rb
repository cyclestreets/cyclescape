class AddSpatialIndexes < ActiveRecord::Migration
  def change
    add_index(:issues, :location, spatial: true)
    add_index(:group_profiles, :location, spatial: true)
    add_index(:library_items, :location, spatial: true)
    add_index(:user_locations, :location, spatial: true)
  end
end
