class MessageThreadsController < ApplicationController
  filter_access_to :show, :edit, :update, :approve, :reject, attribute_check: true

  def index
    threads = ThreadList.recent_public.page(params[:page]).includes(:issue, :group)
    @threads = ThreadListDecorator.decorate_collection threads
  end

  def show
    set_page_title thread.title
    @issue = IssueDecorator.decorate thread.issue if thread.issue
    @messages = thread.messages.includes({ created_by: :profile }, :component).to_a
    @new_message = thread.messages.build
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

  def approve
    thread.approve!
    subscribe_and_notify
  end

  def reject
    thread.reject!
  end

  def permission_denied
    @group = thread.group
    super
  end

  protected

  def subscribe_and_notify
    ThreadSubscriber.subscribe_users thread
    ThreadNotifier.notify_subscribers thread, :new_message, thread.first_message

    NewThreadNotifier.notify_new_thread thread
  end


  def thread
    @thread ||= MessageThread.find params[:id]
  end

  def permitted_params
    params.require(:thread).permit :title, :privacy, :group_id, :issue_id, :tags_string
  end
end
