class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups
    @relevant_issues = current_user.issues_near_locations.order("updated_at DESC")
    @subscribed_threads = current_user.subscribed_threads.limit(4)
    @involved_threads = current_user.involved_threads.limit(4)
  end
end
