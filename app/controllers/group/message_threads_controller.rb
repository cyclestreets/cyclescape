# frozen_string_literal: true

# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_action :group

  def index
    skip_authorization
    set_page_title t("group.message_threads.index.title", group: group.name)

    issue_threads = ThreadList.issue_threads_from_group(group).page(params[:issue_threads_page])
    @issue_threads = ThreadListDecorator.decorate_collection issue_threads

    general_threads = ThreadList.general_threads_from_group(group).page params[:general_threads_page]
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: general_threads + issue_threads)
    @general_threads = ThreadListDecorator.decorate_collection general_threads
  end

  def new
    @thread = group.threads.build privacy: group.default_thread_privacy
    authorize @thread
    @message = @thread.messages.build
  end

  def create
    @thread = group.threads.build
    @thread.assign_attributes permitted_params.merge(created_by: current_user)
    authorize @thread
    super
  end

  protected

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
