# Note inheritance
class Group::MessageModerationsController < MessageThreadsController
  before_filter :group
  filter_access_to :index, attribute_check: true, model: Group

  def index
    @messages = Message.mod_queued.in_group(group.id).page params[:page]
  end

  protected

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
