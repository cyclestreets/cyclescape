class MakeLocationsValid < ActiveRecord::Migration
  def change
    %i[
      constituencies cyclestreets_photo_messages group_profiles issues
      library_items map_messages planning_applications
      street_view_messages user_locations wards
    ].each do |table|
      update "UPDATE #{table} SET location = ST_MakeValid(location)"
    end
  end
end
