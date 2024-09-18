# frozen_string_literal: true

# Note inheritance
class Group::MessageModerationsController < MessageThreadsController
  before_action :group

  def index
    authorize @group, :in_group_committee?

    @messages = Message.mod_queued.in_group(group.id).page params[:page]
  end

  protected

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
