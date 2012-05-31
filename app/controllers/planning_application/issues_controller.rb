class PlanningApplication::IssuesController < IssuesController
  before_filter :load_planning_application

  def new
    @issue = @planning_application.build_issue
    @issue.title = @planning_application.title #truncated
    @issue.location = @planning_application.location
    @issue.description = @planning_application.description
    @issue.tags_string = "planning"
    @start_location = @planning_application.location
  end

  def create
    @issue = current_user.issues.new(params[:issue])

    if @issue.save
      @planning_application.issue = @issue
      @planning_application.save!
      NewIssueNotifier.new_issue(@issue)
      redirect_to @issue
    else
      @start_location = current_user.start_location
      render :new
    end
  end

  protected

  def load_planning_application
    @planning_application = PlanningApplication.find(params[:planning_application_id])
  end
end