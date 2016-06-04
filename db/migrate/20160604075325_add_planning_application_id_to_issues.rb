class AddPlanningApplicationIdToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :planning_application, index: true, foreign_key: true
    planning_issues = select_rows "SELECT id, issue_id FROM planning_applications WHERE issue_id IS NOT NULL"
    ActiveRecord::Base.transaction do
      planning_issues.each do |pi|
        planning_id, issue_id = *pi
        update "UPDATE issues SET planning_application_id = #{planning_id} WHERE id = #{issue_id}"
      end
    end
    rename_column :planning_applications, :issue_id, :zzz_issue_id
  end
end
