class PlanningApplication::IssuesController < IssuesController
  before_filter :load_planning_application

  def new
    @issue = Issue.new
    @issue.title = @planning_application.title #truncated
    @issue.location = @planning_application.location
    @issue.description = @planning_application.description
    @issue.tags_string = "planning"
    @start_location = @planning_application.location
  end

  protected

  def load_planning_application
    @planning_application = PlanningApplication.find(params[:planning_application_id])
  end
end