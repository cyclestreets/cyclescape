class AddEmailStatusIdToUserPrefs < ActiveRecord::Migration
  def change
    add_column :user_prefs, :email_status_id, :integer, default: 0, null: false
    update "UPDATE user_prefs
            SET email_status_id = 1
            WHERE enable_email = #{quoted_true}"
    rename_column :user_prefs, :enable_email, :zz_enable_email
    add_index :user_prefs, :email_status_id
  end
end
