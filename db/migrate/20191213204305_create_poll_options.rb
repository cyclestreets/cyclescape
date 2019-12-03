class CreatePollOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_options do |t|
      t.references :poll_message, foreign_key: true, null: false
      t.text :option, null: false

      t.timestamps
    end
  end
end
