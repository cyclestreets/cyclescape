class AddDeletedAtToSiteComments < ActiveRecord::Migration
  def change
    add_column :site_comments, :deleted_at, :datetime
  end
end
