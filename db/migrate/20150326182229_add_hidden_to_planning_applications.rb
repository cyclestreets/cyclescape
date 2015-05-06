class AddHiddenToPlanningApplications < ActiveRecord::Migration
  def change
    add_column :planning_applications, :hidden, :boolean, default: false, null: false
  end
end
