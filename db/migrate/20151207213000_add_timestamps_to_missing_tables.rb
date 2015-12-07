class AddTimestampsToMissingTables < ActiveRecord::Migration
  def change
    %i(document_messages library_item_messages library_documents
       library_notes user_profiles).each do |table|
      add_timestamps table
    end
    %i(deadline_messages link_messages photo_messages).each do |table|
      add_column(table, :updated_at, :datetime)
    end
  end
end
