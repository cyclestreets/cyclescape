class AddMoreNotificationAndSubscriptionPreferences < ActiveRecord::Migration
  def change
    add_column :user_prefs, :notify_new_user_locations_issue_thread, :boolean, null: false, default: false
    add_column :user_prefs, :subscribe_new_group_thread, :boolean, null: false, default: false
    add_column :user_prefs, :subscribe_new_user_location_issue_thread, :boolean, null: false, default: false
  end
end
