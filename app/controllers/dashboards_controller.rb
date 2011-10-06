class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups
  end
end
