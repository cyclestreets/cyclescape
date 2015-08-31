class AddExternalUrlToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :external_url, :string
  end
end
