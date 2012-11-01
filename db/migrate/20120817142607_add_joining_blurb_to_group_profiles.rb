class AddJoiningBlurbToGroupProfiles < ActiveRecord::Migration
  def change
    add_column :group_profiles, :joining_instructions, :text
  end
end
