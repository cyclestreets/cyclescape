class ReformatPlanningApplications < ActiveRecord::Migration
  def up
    remove_column :planning_applications, :openlylocal_id
    remove_column :planning_applications, :openlylocal_url
    remove_column :planning_applications, :council_name
    add_column :planning_applications, :authority_name, :string
    add_index :planning_applications, [:uid], unique: true
  end

  def down
    add_column :planning_applications, :openlylocal_id, :integer, null: false
    add_column :planning_applications, :openlylocal_url, :string
    remove_index :planning_applications, [:uid], unique: true
    add_column :planning_applications, :council_name, :string
    remove_column :planning_applications, :authority_name
  end
end
