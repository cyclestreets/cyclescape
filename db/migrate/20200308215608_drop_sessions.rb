class DropSessions < ActiveRecord::Migration[5.2]
  def change
    drop_table :sessions
  end
end
