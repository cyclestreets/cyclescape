class AddPhotoPreviewHeightToPhotoMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :photo_messages, :photo_preview_height, :integer
  end
end
