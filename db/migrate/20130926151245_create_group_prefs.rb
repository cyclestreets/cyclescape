class CreateGroupPrefs < ActiveRecord::Migration

  # Inline 'stub' class so we can create prefs for all groups during migration
  class Group < ActiveRecord::Base
    has_one :prefs, class_name: "GroupPref"
  end

  def up
    create_table :group_prefs do |t|
      t.integer :group_id, null: false
      t.integer :membership_secretary_id
      t.boolean :notify_membership_requests, null: false, default: true
      t.timestamps
    end

    add_index :group_prefs, :group_id, unique: true

    Group.all.each do |group|
      group.build_prefs.save!
    end
  end

  def down
    drop_table :group_prefs
  end
end
