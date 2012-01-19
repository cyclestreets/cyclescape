class GroupsController < ApplicationController
  def show
    if params[:id]
      @group = Group.find(params[:id])
    else current_group
      @group = current_group
    end
    @recent_threads = @group.threads.order("created_at DESC").limit(10)
    @recent_issues = @group.recent_issues.limit(10)
  end
end
