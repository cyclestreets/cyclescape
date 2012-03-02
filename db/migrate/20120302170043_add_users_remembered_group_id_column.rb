class AddUsersRememberedGroupIdColumn < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :remembered_group_id
    end
  end
end
