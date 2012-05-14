class AddUserInvolvementPrefs < ActiveRecord::Migration
  def change
    add_column :user_prefs, :involve_my_locations, :string, default: "subscribe", null: false
    add_column :user_prefs, :involve_my_groups, :string, default: "notify", null: false
    add_column :user_prefs, :involve_my_groups_admin, :boolean, default: false, null: false
    add_column :user_prefs, :enable_email, :boolean, default: false, null: false
  end
end
