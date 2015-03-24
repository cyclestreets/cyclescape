class AddStartDateToPlanningApplications < ActiveRecord::Migration
  def change
    add_column :planning_applications, :start_date, :date
  end
end
