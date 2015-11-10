class AddNewUserEmailToGroupProfiles < ActiveRecord::Migration
  def change
    add_column :group_profiles, :new_user_email, :text
  end
end
