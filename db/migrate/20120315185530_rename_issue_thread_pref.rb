class RenameIssueThreadPref < ActiveRecord::Migration
  def up
    rename_column :user_prefs, :notify_new_issue_thread, :notify_new_group_location_issue
  end

  def down
    rename_column :user_prefs, :notify_new_group_location_issue, :notify_new_issue_thread
  end
end
