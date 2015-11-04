class AddSpatialIndexes < ActiveRecord::Migration
  def change
    add_index(:issues, :location, using: :gist)
    add_index(:group_profiles, :location, using: :gist)
    add_index(:library_items, :location, using: :gist)
    add_index(:user_locations, :location, using: :gist)
  end
end
