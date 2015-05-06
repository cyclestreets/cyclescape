class AlterPlanningApplications < ActiveRecord::Migration
  def up
    change_column :planning_applications, :url, :text
    change_column :planning_applications, :openlylocal_url, :text
    change_column :planning_applications, :address, :text
  end

  def down
    change_column :planning_applications, :url, :string
    change_column :planning_applications, :openlylocal_url, :string
    change_column :planning_applications, :address, :string
  end
end
