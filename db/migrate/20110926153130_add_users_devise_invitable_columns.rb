class AddUsersDeviseInvitableColumns < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :invitation_token, limit: 60
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.index :invitation_token
    end

    change_column_null :users, :encrypted_password, true
  end
end
