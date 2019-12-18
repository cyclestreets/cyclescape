class CreatePollVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_votes do |t|
      t.references :user, foreign_key: true, null: false
      t.references :poll_option, foreign_key: true, null: false

      t.timestamps
    end

    add_index :poll_votes, [:user_id, :poll_option_id], unique: true
  end
end
