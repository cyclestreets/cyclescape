class AllowNullCategoryUserLocations < ActiveRecord::Migration
  def change
    change_column_null :user_locations, :category_id, true
  end
end
