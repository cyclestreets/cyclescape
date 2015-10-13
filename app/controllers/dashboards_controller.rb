class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups

    @relevant_issues = IssueDecorator.decorate_collection(current_user.issues_near_locations.order('updated_at DESC').limit(12).includes(:created_by, :tags))

    subscribed_threads = current_user.subscribed_threads.order_by_latest_message.
      limit(12).includes(:issue, latest_message: [:component, :created_by])
    @subscribed_threads = ThreadListDecorator.decorate_collection subscribed_threads

    group_threads = ThreadList.recent_from_groups(current_user.groups, 8).includes(:group, issue: :tags).references(:group)
    @group_threads = ThreadListDecorator.decorate_collection group_threads

    deadline_threads = ThreadList.with_upcoming_deadlines(current_user, 12).includes(:issue)
    @deadline_threads = ThreadListDecorator.decorate_collection deadline_threads

    prioritised_threads = current_user.prioritised_threads.order('priority desc').
      order_by_latest_message.limit(20).includes(:issue, latest_message: [:component, :created_by])
    @prioritised_threads = ThreadListDecorator.decorate_collection(prioritised_threads)

    planning_applications = current_user.planning_applications_near_locations.ordered
      .not_hidden.page params[:planning_page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
  end

  def search
    # Ideally, this would be delegated to the different controllers.

    @query = params[:query]

    # Threads, with permission check
    unfiltered_results = MessageThread.find_with_index @query
    results = unfiltered_results.select { |t| permitted_to?(:show, t) }
    @threads = ThreadListDecorator.decorate_collection results

    # Issues
    issues = Issue.find_with_index @query
    @issues = IssueDecorator.decorate_collection issues

    # Library Items
    library_items = Library::Item.find_with_index @query
    @library_items = Library::ItemDecorator.decorate_collection library_items

    # Users? Groups?
  end
end
