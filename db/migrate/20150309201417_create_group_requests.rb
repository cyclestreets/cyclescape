class CreateGroupRequests < ActiveRecord::Migration
  def change
    create_table :group_requests do |t|
      t.string :status
      t.references :user, null: false
      t.references :actioned_by
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :default_thread_privacy, default: "public", null: false
      t.string :website
      t.string :email, null: false
      t.text :message

      t.timestamps
    end
    add_index :group_requests, :user_id
    add_index :group_requests, :name, unique: true
    add_index :group_requests, :short_name, unique: true
  end
end
