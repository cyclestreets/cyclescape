class MessageThreadsController < ApplicationController
  filter_access_to :show, :edit, :update, attribute_check: true

  def index
    threads = ThreadList.recent_public.page(params[:page]).includes(:issue, :group)
    @threads = ThreadListDecorator.decorate(threads)
  end

  def show
    load_thread
    set_page_title @thread.title
    @issue = IssueDecorator.decorate(@thread.issue) if @thread.issue
    @messages = @thread.messages.includes({ created_by: :profile }, :component).all
    @new_message = @thread.messages.build
    @subscribers = @thread.subscribers
    @library_items = Library::Item.find_by_tags_from(@thread).limit(5)
    @tag_panel = TagPanelDecorator.new(@thread, form_url: thread_tags_path(@thread))

    @view_from = nil
    if current_user
      if current_user.viewed_thread?(@thread)
        @view_from = @messages.detect { |m| m.created_at >= current_user.viewed_thread_at(@thread) } || @messages.last
      end
      ThreadRecorder.thread_viewed(@thread, current_user)
    end
  end

  def edit
    load_thread
  end

  def update
    load_thread

    if @thread.update_attributes(params[:thread])
      set_flash_message(:success)
      redirect_to thread_path(@thread)
    else
      render :edit
    end
  end

  def destroy
    load_thread

    if @thread.destroy
      set_flash_message(:success)
      redirect_to threads_path
    else
      set_flash_message(:failure)
      redirect_to @thread
    end
  end

  protected

  def load_thread
    @thread = MessageThread.find(params[:id])
  end
end
