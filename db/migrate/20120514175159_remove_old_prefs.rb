class RemoveOldPrefs < ActiveRecord::Migration
  def up
    remove_column :user_prefs, :notify_subscribed_threads
    remove_column :user_prefs, :notify_new_user_locations_issue
    remove_column :user_prefs, :notify_new_group_thread
    remove_column :user_prefs, :notify_new_group_location_issue
    remove_column :user_prefs, :notify_new_user_locations_issue_thread
    remove_column :user_prefs, :subscribe_new_group_thread
    remove_column :user_prefs, :subscribe_new_user_location_issue_thread
  end

  def down
    add_column :user_prefs, :notify_subscribed_threads,                :boolean, :default => true,  :null => false
    add_column :user_prefs, :notify_new_user_locations_issue,          :boolean, :default => false, :null => false
    add_column :user_prefs, :notify_new_group_thread,                  :boolean, :default => true,  :null => false
    add_column :user_prefs, :notify_new_group_location_issue,          :boolean, :default => false, :null => false
    add_column :user_prefs, :notify_new_user_locations_issue_thread,   :boolean, :default => false, :null => false
    add_column :user_prefs, :subscribe_new_group_thread,               :boolean, :default => false, :null => false
    add_column :user_prefs, :subscribe_new_user_location_issue_thread, :boolean, :default => false, :null => false
  end
end
