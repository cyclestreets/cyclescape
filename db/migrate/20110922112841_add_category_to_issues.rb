class AddCategoryToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :category_id, :integer
  end
end
