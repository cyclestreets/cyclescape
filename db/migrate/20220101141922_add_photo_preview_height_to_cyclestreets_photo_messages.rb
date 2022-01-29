class AddPhotoPreviewHeightToCyclestreetsPhotoMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :cyclestreets_photo_messages, :photo_preview_height, :integer
  end
end
