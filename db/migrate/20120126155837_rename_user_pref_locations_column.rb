class RenameUserPrefLocationsColumn < ActiveRecord::Migration
  def up
    rename_column :user_prefs, :notify_new_home_locations_issue, :notify_new_user_locations_issue
  end

  def down
    rename_column :user_prefs, :notify_new_user_locations_issue, :notify_new_home_locations_issue
  end
end
