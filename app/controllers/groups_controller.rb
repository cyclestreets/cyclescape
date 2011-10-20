class GroupsController < ApplicationController

  def show
    @group = Group.find(params[:id])
    @recent_threads = @group.threads.order("created_at DESC").limit(10)
    @recent_issues = Issue.where("st_intersects(location, ?)", @group.profile.location).order("created_at DESC").limit(10)
  end
end
