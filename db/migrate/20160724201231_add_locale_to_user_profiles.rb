class AddLocaleToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :locale, :integer
  end
end
