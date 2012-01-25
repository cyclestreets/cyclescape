class GroupsController < ApplicationController
  def show
    if params[:id]
      @group = Group.find(params[:id])
    elsif current_group
      @group = current_group
    end

    @group = GroupDecorator.decorate(@group)

    if @group
      @recent_threads = @group.threads.order("created_at DESC").limit(10)
      @recent_issues = @group.recent_issues.limit(10)
    else
      redirect_to root_url(subdomain: 'www')
    end
  end
end
