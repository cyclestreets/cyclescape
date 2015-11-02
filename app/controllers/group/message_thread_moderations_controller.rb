# Note inheritance
class Group::MessageThreadModerationsController < MessageThreadsController
  before_filter :group
  filter_access_to :index, attribute_check: true, model: Group

  def index
    issue_threads = ThreadList.mod_queued_from_group(group).page params[:page]
    @threads = ThreadListDecorator.decorate_collection issue_threads
  end

  protected

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
