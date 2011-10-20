class GroupsController < ApplicationController

  def show
    @group = Group.find(params[:id])
    @recent_threads = @group.threads.limit(10)
  end
end
