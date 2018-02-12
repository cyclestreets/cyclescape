class AddLogoUidToGroupProfiles < ActiveRecord::Migration
  def change
    add_column :group_profiles, :logo_uid, :string
  end
end
