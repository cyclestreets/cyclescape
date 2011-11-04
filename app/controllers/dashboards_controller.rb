class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups
    @relevant_issues = current_user.issues_near_locations
  end
end
