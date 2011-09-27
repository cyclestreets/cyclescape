class Group::MembersController < ApplicationController
  def index
    @group = Group.find(params[:group_id])
    @committee = @group.committee_members.all
    @members = @group.normal_members.all
  end
end
