class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.integer :user_id, null: false
      t.string :picture_uid
      t.string :website
      t.text :about
    end
  end
end
