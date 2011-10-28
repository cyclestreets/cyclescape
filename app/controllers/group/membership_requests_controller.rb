class Group::MembershipRequestsController < ApplicationController

  def new
    @group = Group.find(params[:group_id])
    @request = @group.membership_requests.build
  end

  def create
    @group = Group.find(params[:group_id])
    @request = @group.membership_requests.build({user: current_user})

    if @request.save
      redirect_to @group, notice: t(".groups.membership_requested")
    else
      render :new
    end
  end
end