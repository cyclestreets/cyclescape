class CreateHtmlIssues < ActiveRecord::Migration
  def up
    create_table :html_issues do |t|
      t.datetime :created_at, null: false
    end
    insert "INSERT INTO html_issues (created_at) VALUES (CURRENT_TIMESTAMP)"
  end

  def down
    drop_table :html_issues
  end
end
