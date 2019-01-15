# frozen_string_literal: true

class MessageThreadsController < ApplicationController
  filter_access_to :show, :edit, :update, :approve, :reject, :close, :open, :destroy, attribute_check: true
  include MessageCreator

  def index
    threads = ThreadList.recent_public.page(params[:page])
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)
    @threads = ThreadListDecorator.decorate_collection threads
  end

  def show
    set_page_title thread.title
    @issue = IssueDecorator.decorate thread.issue if thread.issue
    @messages = thread.messages.approved.includes(:component, created_by: [:profile, :groups, :requested_groups])
    @library_items = Library::Item.find_by_tags_from(thread).limit(5)
    @tag_panel = TagPanelDecorator.new(thread, form_url: thread_tags_path(thread))

    @view_from = nil
    if current_user
      @subscribers = current_user.can_view thread.subscribers

      if current_user.viewed_thread? thread
        @view_from = @messages.detect { |m| m.created_at >= current_user.viewed_thread_at(thread) } || @messages.last
      end
      ThreadRecorder.thread_viewed thread, current_user
    else
      @subscribers = thread.subscribers.is_public
    end
    @subscribers = @subscribers.ordered(thread.group_id).includes(:groups)
  end

  def edit
    thread
  end

  def update
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
    @group ||= thread.try(:group)
    super
  end

  protected

  def create
    # Thread is created in issue or group message thread controller
    @message = create_message(thread)
    if thread.save
      redirect_on_check_reason(@message, spam_path: home_path, clean_path: thread_path(thread))
    else
      @available_groups = current_user.groups
      render :new
    end
  end

  def thread
    @thread ||= begin
                  scope = MessageThread.all
                  scope = scope.approved unless current_user.try(:admin?)
                  scope.find params[:id]
                end
  end

  def permitted_params
    params.require(:thread).permit :title, :privacy, :group_id, :issue_id, :tags_string
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end
end
