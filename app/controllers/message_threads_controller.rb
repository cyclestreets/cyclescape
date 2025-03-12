# frozen_string_literal: true

class MessageThreadsController < ApplicationController
  include MessageCreator

  def index
    skip_authorization

    threads = ThreadList.recent_public.page(params[:page])
    @user_favourites = current_user&.thread_favourites&.where(thread: threads)
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)
    @threads = ThreadListDecorator.decorate_collection threads
    @user_subscriptions = current_user.thread_subscriptions.active.where(thread: threads).to_a if current_user
  end

  def show
    messages = thread.messages.approved

    respond_to do |format|
      format.html do
        set_page_title thread.title
        @issue = IssueDecorator.decorate thread.issue if thread.issue

        if current_user
          @subscribers = current_user.can_view thread.subscribers

          last_viewed = current_user.viewed_thread_at(thread)
          ThreadRecorder.thread_viewed thread, current_user
        else
          @subscribers = thread.subscribers.is_public.includes(:profile)
        end
        messages = messages.after_date_with_n_before(after_date: last_viewed, n_before: 10) if last_viewed

        @messages = messages.includes(
          *Message::COMPONENT_TYPES, :completing_action_messages, :votes, created_by: %i[profile memberships groups membership_requests]
        )

        if last_viewed
          @view_from = @messages.detect { |m| m.created_at >= last_viewed } || @messages.last
        end

        @initially_loaded_from = @messages.first&.created_at&.iso8601

        @library_items = Library::Item.find_by_tags_from(thread).limit(5)

        @subscribers = @subscribers.ordered(thread.group_id).includes(:groups)
      end
      format.turbo_stream do
        initially_loaded_from = Time.zone.iso8601(params[:from])
        messages = messages.before_date_with_n_before(before_date: initially_loaded_from, n_before: 40)

        @messages = messages.includes(
          *Message::COMPONENT_TYPES, :completing_action_messages, created_by: %i[profile memberships groups membership_requests]
        ).to_a.reverse!

        render turbo_stream: [
          turbo_stream.prepend(
            :messages,
            collection: @messages, partial: "messages/message", locals: { thread: @thread }, cached: true
          ),
          turbo_stream.replace(:load_more, partial: "message_threads/load_more")
        ]
      end
    end
  end

  def edit
    thread
  end

  def update
    thread.updated_by = current_user
    if thread.update permitted_params
      set_flash_message :success
      redirect_to thread_path thread
    else
      render :edit
    end
  end

  def destroy
    if thread.destroy
      set_flash_message :success
      redirect_to threads_path
    else
      set_flash_message :failure
      redirect_to thread
    end
  end

  def close
    thread.close_by! current_user
    redirect_to thread_path thread
  end

  def open
    thread.open_by! current_user
    redirect_to thread_path thread
  end

  def permission_denied
    @group ||= thread(auth: false).try(:group)
    super
  end

  protected

  def create
    # Thread is created in issue or group message thread controller
    @message = create_message(thread)
    if thread.save
      redirect_on_check_reason(@message, spam_path: home_path, clean_path: thread_path(thread))
    else
      render :new
    end
  end

  def thread(auth: true)
    @thread ||= begin
                  scope = MessageThread.all
                  scope = scope.approved unless current_user.try(:admin?)
                  thread = scope.find params[:id]
                  authorize thread if auth
                  thread
                end
  end

  def permitted_params
    permitted =
      if Pundit.policy!(current_user, @thread).edit_all_fields?
        %i[privacy group_id issue_id tags_string]
      else
        []
      end
    params.require(:thread).permit(*([:title] + permitted))
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end
end
