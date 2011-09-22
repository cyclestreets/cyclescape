class Group::MembersController < ApplicationController
  def index
    @group = Group.find(params[:group_id])
    @members = @group.members.all
  end
end
