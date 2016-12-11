class CreatePotentialMembers < ActiveRecord::Migration
  def change
    create_table :potential_members do |t|
      t.references :group, index: true, foreign_key: true
      t.string :email_hash

      t.timestamps null: false
    end
    add_index :potential_members, :email_hash, unique: true
  end
end
