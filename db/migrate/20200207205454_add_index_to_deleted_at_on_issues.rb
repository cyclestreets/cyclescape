class AddIndexToDeletedAtOnIssues < ActiveRecord::Migration[5.2]
  def change
    add_index :issues, :deleted_at
  end
end
