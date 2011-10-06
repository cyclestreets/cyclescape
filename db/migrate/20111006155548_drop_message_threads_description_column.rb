class DropMessageThreadsDescriptionColumn < ActiveRecord::Migration
  def up
    remove_column :message_threads, :description
  end

  def down
    add_column :message_threads, :description, :text
  end
end
