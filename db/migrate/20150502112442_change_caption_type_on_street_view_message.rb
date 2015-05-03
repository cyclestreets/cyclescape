class ChangeCaptionTypeOnStreetViewMessage < ActiveRecord::Migration
  def up
    remove_column :street_view_messages, :caption
    add_column :street_view_messages, :caption, :text
  end

  def down
    remove_column :street_view_messages, :caption
    add_column :street_view_messages, :caption, :string
  end
end
