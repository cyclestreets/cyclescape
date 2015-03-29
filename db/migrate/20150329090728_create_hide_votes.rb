class CreateHideVotes < ActiveRecord::Migration
  def change
    create_table :hide_votes do |t|
      t.belongs_to :planning_application
      t.belongs_to :user

      t.timestamps
    end
    add_index :hide_votes, [:planning_application_id, :user_id], unique: true
  end
end
