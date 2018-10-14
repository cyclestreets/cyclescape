class AddPhotoNameForDragonfly < ActiveRecord::Migration
  def change
    add_column :photo_messages, :photo_name, :string
    add_column :issues, :photo_name, :string
    add_column :cyclestreets_photo_messages, :photo_name, :string
  end
end
