class AddRelevantToPlanningApplications < ActiveRecord::Migration
  def change
    add_column :planning_applications, :relevant, :boolean, null: false, default: true
  end
end
