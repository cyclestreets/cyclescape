class RemovePlanningUidConstraint < ActiveRecord::Migration
  def change
    remove_index :planning_applications, [:uid]
    add_index :planning_applications, [:uid], unique: false
  end
end
