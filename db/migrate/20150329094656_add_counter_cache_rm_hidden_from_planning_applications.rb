class AddCounterCacheRmHiddenFromPlanningApplications < ActiveRecord::Migration
  def change
    remove_column :planning_applications, :hidden
    add_column :planning_applications, :hide_votes_count, :integer, default: 0
  end
end
