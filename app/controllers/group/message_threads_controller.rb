# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_filter :group

  def index
    set_page_title t('group.message_threads.index.title', group: group.name)

    issue_threads = ThreadList.issue_threads_from_group(group).page params[:issue_threads_page]
    @issue_threads = ThreadListDecorator.decorate_collection issue_threads

    general_threads = ThreadList.general_threads_from_group(group).page params[:general_threads_page]
    @unviewed_thread_ids = (general_threads.unviewed_for(current_user).ids + issue_threads.unviewed_for(current_user).ids).uniq
    @general_threads = ThreadListDecorator.decorate_collection general_threads
  end

  def new
    @thread = group.threads.build privacy: group.default_thread_privacy
    @message = @thread.messages.build
  end

  def create
    @thread = group.threads.build permitted_params.merge(created_by: current_user)
    super
  end

  protected

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
