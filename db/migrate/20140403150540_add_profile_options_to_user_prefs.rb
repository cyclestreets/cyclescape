class AddProfileOptionsToUserPrefs < ActiveRecord::Migration
  def change
    add_column :user_prefs, :profile_visibility, :string, default: 'public', null: false
  end
end
