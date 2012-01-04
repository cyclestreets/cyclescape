class AddIssuesPhotoColumns < ActiveRecord::Migration
  def up
    add_column :issues, :photo_uid, :string
  end

  def down
    remove_column :issues, :photo_uid
  end
end
