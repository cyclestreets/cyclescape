# frozen_string_literal: true

class PlanningApplication::IssuesController < IssuesController
  before_action :load_planning_application
  before_action :check_for_issue

  def new
    @issue = @planning_application.populate_issue
    @start_location = @planning_application.location || index_start_location
    render 'issues/new'
  end

  protected

  def load_planning_application
    @planning_application = PlanningApplication.find params[:planning_application_id]
  end

  def check_for_issue
    if @planning_application.issue
      set_flash_message :already
      redirect_to planning_application_path @planning_application
    end
  end
end
