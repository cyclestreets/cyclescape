class AddDeadlineToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :deadline, :datetime
  end
end
