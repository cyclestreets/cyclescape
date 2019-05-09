# frozen_string_literal: true

class Group::MembersController < ApplicationController
  before_action :load_group
  filter_access_to :all, attribute_check: true, model: Group

  def index
    set_page_title t("group.members.index.title", group: @group.name)

    @committee = @group.committee_members
    @members = @group.normal_members
    @pending_requests = (@group.pending_membership_requests.count > 0)
  end

  protected

  def load_group
    @group = Group.find(params[:group_id])
  end
end
