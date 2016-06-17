class CreatePlanningFilters < ActiveRecord::Migration
  def change
    create_table :planning_filters do |t|
      t.string :authority
      t.string :rule

      t.timestamps null: false
    end
  end
end
