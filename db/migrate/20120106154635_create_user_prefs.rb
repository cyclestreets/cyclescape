class CreateUserPrefs < ActiveRecord::Migration
  def change
    create_table :user_prefs do |t|
      t.integer :user_id, null: false
      t.boolean :notify_subscribed_threads, null: false, default: true
      t.boolean :notify_new_home_locations_issue, null: false, default: false
      t.boolean :notify_new_group_thread, null: false, default: true
      t.boolean :notify_new_issue_thread, null: false, default: false
    end

    add_index :user_prefs, :user_id, unique: true
  end
end
