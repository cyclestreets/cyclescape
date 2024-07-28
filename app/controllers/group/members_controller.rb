# frozen_string_literal: true

class Group::MembersController < ApplicationController
  before_action :load_group

  def index
    authorize @group, policy_class: GroupMemberPolicy
    set_page_title t("group.members.index.title", group: @group.name)

    @committee = @group.committee_members
    @members = @group.normal_members
    @pending_requests = @group.pending_membership_requests.exists?
  end

  protected

  def load_group
    @group = Group.find(params[:group_id])
  end
end
