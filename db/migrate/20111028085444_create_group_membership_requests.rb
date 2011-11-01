class CreateGroupMembershipRequests < ActiveRecord::Migration
  def change
    create_table :group_membership_requests do |t|
      t.integer :user_id, null: false
      t.integer :group_id, null: false
      t.string :status, null: false

      t.integer :actioned_by_id

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.timestamps
    end
  end
end
