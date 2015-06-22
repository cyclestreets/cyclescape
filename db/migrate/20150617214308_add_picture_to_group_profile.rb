class AddPictureToGroupProfile < ActiveRecord::Migration
  def change
    add_column :group_profiles, :picture_uid, :string
    add_column :group_profiles, :picture_name, :string
  end
end
