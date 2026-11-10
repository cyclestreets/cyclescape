# frozen_string_literal: true

# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_action :group

  def index
    set_page_title t("group.message_threads.index.title", group: group.name)
    super
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

  def threads_scope
    scope =
      if current_user
        case @view
        when "all" then MessageThread.order_by_latest_message
        when "general" then MessageThread.order_by_latest_message.without_issue
        when "favourites" then current_user.favourite_threads.order_by_latest_message
        when "deadlines" then current_user.subscribed_threads.with_upcoming_deadlines
        when "popular" then MessageThread.popular
        else current_user.subscribed_threads.order_by_latest_message
        end
      else
        MessageThread.is_public.order_by_latest_message
      end
    scope.where(group: group)
  end

  def threads_intro_partial
    "group/message_threads/intro"
  end

  def group
    @group ||= Group.find_by(id: params[:group_id]) || current_group
  end
end
