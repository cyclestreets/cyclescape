class AddGroupDefaultThreadPrivacy < ActiveRecord::Migration
  def up
    add_column :groups, :default_thread_privacy, :string, null: false, default: 'public'
  end

  def down
    remove_column :groups, :default_thread_privacy
  end
end
