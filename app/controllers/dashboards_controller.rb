class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups
    @relevant_issues = Issue.all(limit: 2)
  end
end
