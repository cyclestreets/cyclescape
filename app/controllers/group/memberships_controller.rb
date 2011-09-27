class Group::MembershipsController < ApplicationController
  def new
    @group = Group.find(params[:group_id])
    @membership = @group.memberships.new
    @membership.build_user
  end

  def create
    @group = Group.find(params[:group_id])
    @membership = @group.memberships.new(params[:group_membership])

    if @membership.save
      redirect_to group_members_path
    else
      render :new
    end
  end
end
