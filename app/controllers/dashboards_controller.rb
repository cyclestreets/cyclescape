class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups

    @relevant_issues = IssueDecorator.decorate(current_user.issues_near_locations.order("updated_at DESC").limit(12).includes(:created_by, :tags))

    subscribed_threads = current_user.subscribed_threads.order_by_latest_message.limit(12).includes(:issue, latest_message: [:component, :created_by])
    @subscribed_threads = ThreadListDecorator.decorate(subscribed_threads)

    group_threads = ThreadList.recent_from_groups(current_user.groups, 8).includes({issue: :tags}, :group)
    @group_threads = ThreadListDecorator.decorate(group_threads)

    deadline_threads = ThreadList.with_upcoming_deadlines(current_user, 12).includes(:issue)
    @deadline_threads = ThreadListDecorator.decorate(deadline_threads)

    prioritised_threads = current_user.prioritised_threads.order("priority desc").order_by_latest_message.limit(20).includes(:issue, latest_message: [:component, :created_by])
    @prioritised_threads = ThreadListDecorator.decorate(prioritised_threads)
  end

  def search
    # Ideally, this would be delegated to the different controllers.

    @query = params[:query]

    # Threads, with permission check
    unfiltered_results = MessageThread.find_with_index(@query)
    results = unfiltered_results.select{ |t| permitted_to?(:show, t) }
    @threads = ThreadListDecorator.decorate(results)

    # Issues
    issues = Issue.find_with_index(@query)
    @issues = IssueDecorator.decorate(issues)

    # Library Items
    library_items = Library::Item.find_with_index(@query)
    @library_items = Library::ItemDecorator.decorate(library_items)

    # Users? Groups?
  end
end
