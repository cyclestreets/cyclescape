class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups
    @relevant_issues = current_user.issues_near_locations.order("updated_at DESC")
    @subscribed_threads = current_user.subscribed_threads.limit(4)
    involved_threads = ThreadList.recent_involved_with(current_user, 4)
    @involved_threads = ThreadListDecorator.decorate(involved_threads)

    group_threads = ThreadList.recent_from_groups(current_user.groups, 4)
    @group_threads = ThreadListDecorator.decorate(group_threads)
  end
end
