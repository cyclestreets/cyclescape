class ChangeUrlToTextOnIssues < ActiveRecord::Migration
  def up
    change_column :issues, :external_url, :text
  end

  def down
    change_column :issues, :external_url, :string
  end
end
