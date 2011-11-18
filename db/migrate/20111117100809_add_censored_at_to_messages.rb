class AddCensoredAtToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :censored_at, :datetime
  end

  def down
    remove_column :messages, :censored_at
  end
end
