# frozen_string_literal: true

# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_action :group

  def index
    skip_authorization
    set_page_title t("group.message_threads.index.title", group: group.name)

    @ar_threads =
      if current_user
        case params[:view]
        when nil, "all"
          if group.has_member?(current_user)
            MessageThread.order_by_latest_message
          else
            MessageThread.is_public.order_by_latest_message
          end
        when "general"
          MessageThread.order_by_latest_message.without_issue
        when "favourites"
          current_user.favourite_threads.order_by_latest_message
        when "mine"
          current_user.subscribed_threads.order_by_latest_message
        when "deadlines"
          current_user.subscribed_threads.with_upcoming_deadlines
        when "popular"
          MessageThread.popular
        end
      else
        MessageThread.is_public.order_by_latest_message.where(group: group).page(params[:page])
      end
    @ar_threads = @ar_threads.approved.where(group: group).page(params[:page])

    thread_ids = @ar_threads.map(&:id)
    if current_user
      @user_favourites = current_user.thread_favourites.where(thread_id: thread_ids).to_a
      @user_subscriptions = current_user.thread_subscriptions.where(thread_id: thread_ids).active.to_a
    end

    @threads = ThreadListDecorator.decorate_collection @ar_threads
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: @ar_threads)
    @latest_activity = Message.where(thread_id: thread_ids).latest_activities
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
