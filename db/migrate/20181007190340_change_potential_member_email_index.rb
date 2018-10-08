class ChangePotentialMemberEmailIndex < ActiveRecord::Migration
  def change
    remove_index :potential_members, column: :email_hash, unique: true
    add_index :potential_members, [:email_hash, :group_id], unique: true
  end
end
