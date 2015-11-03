class AddFieldsToPlanningApplications < ActiveRecord::Migration
  def change
    add_column :planning_applications, :link, :string
    add_column :planning_applications, :end_date, :datetime
    add_column :planning_applications, :when_updated, :datetime
    add_column :planning_applications, :api_get, :datetime
  end
end
