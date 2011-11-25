class ConvertIssueCategoriesToTags < ActiveRecord::Migration
  def up
    # Safe way to migrate data while removing category relation
    categories = execute("SELECT i.id, ic.name FROM issues i JOIN issue_categories ic ON i.category_id = ic.id").values
    Issue.all.each do |issue|
      issue.update_attributes(tags_string: categories.detect {|c| c[0].to_i == issue.id }.second)
    end
    remove_column :issues, :category_id
    drop_table :issue_categories
  end

  def down
    CreateIssueCategories.migrate :up
  end
end
