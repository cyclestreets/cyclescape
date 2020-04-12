class AddNewAppFieldsToPlanningApplications < ActiveRecord::Migration[5.2]
  def change
    remove_column :planning_applications, :openlylocal_council_url
    remove_column :planning_applications, :zzz_issue_id
    add_column :planning_applications, :app_size, :string
    add_column :planning_applications, :app_state, :string
    add_column :planning_applications, :app_type, :string
    add_column :planning_applications, :when_updated, :datetime
    add_column :planning_applications, :associated_id, :string
    add_index :planning_applications, :associated_id
  end
end
