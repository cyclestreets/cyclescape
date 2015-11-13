class CreateMessageThreadCloses < ActiveRecord::Migration
  def change
    create_table :message_thread_closes do |t|
      t.references :user, index: true, foreign_key: true
      t.references :message_thread, index: true, foreign_key: true
      t.string :event

      t.timestamps null: false
    end
  end
end
