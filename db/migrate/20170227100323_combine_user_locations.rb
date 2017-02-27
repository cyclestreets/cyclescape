class CombineUserLocations < ActiveRecord::Migration
  def change
    select_rows("SELECT ST_UNION(ST_MakeValid(location)) AS union_location, user_id
                    FROM user_locations GROUP BY user_id").each do |row|
      union_location, user_id = *row
      where = "WHERE user_id = #{user_id}"
      first_loc_id = select_values("SELECT id FROM user_locations #{where} ORDER BY created_at ASC LIMIT 1")[0]

      going_to_be_deleted = select_values("SELECT id FROM user_locations #{where} AND id != #{first_loc_id}")

      next if going_to_be_deleted.blank?

      update("UPDATE user_locations SET location = '#{union_location}' WHERE id = #{first_loc_id}")

      delete("DELETE FROM user_locations WHERE id IN (#{going_to_be_deleted.join(', ')})")
    end

    remove_index :user_locations, :user_id
    add_index :user_locations, :user_id, unique: true
  end
end
