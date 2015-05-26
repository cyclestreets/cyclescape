class MigrateProfileVisabilityToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :visibility, :string, default: 'public', null: false
    execute "UPDATE user_profiles
             SET visibility = user_prefs.profile_visibility
             FROM user_prefs
             WHERE user_prefs.user_id = user_profiles.user_id"
    rename_column :user_prefs, :profile_visibility, :zz_profile_visibility

  end
end
