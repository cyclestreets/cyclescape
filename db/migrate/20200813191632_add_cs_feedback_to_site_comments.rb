class AddCsFeedbackToSiteComments < ActiveRecord::Migration[5.2]
  def change
    add_column :site_comments, :sent_to_cyclestreets_at, :datetime
    add_column :site_comments, :cyclestreets_response, :jsonb
  end
end
