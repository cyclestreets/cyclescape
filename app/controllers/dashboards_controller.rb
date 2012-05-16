class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups

    @relevant_issues = IssueDecorator.decorate(current_user.issues_near_locations.order("updated_at DESC"))

    @subscribed_threads = ThreadListDecorator.decorate(current_user.subscribed_threads.limit(8))

    group_threads = ThreadList.recent_from_groups(current_user.groups, 8)
    @group_threads = ThreadListDecorator.decorate(group_threads)

    deadline_threads = ThreadList.with_upcoming_deadlines(current_user, 8)
    @deadline_threads = ThreadListDecorator.decorate(deadline_threads)
  end
end
