class MessageThreadsController < ApplicationController
  filter_access_to :show, :edit, :update, attribute_check: true

  def index
    threads = ThreadList.recent_public.page(params[:page])
    @threads = ThreadListDecorator.decorate(threads)
  end

  def show
    load_thread
    set_page_title @thread.title
    @issue = IssueDecorator.decorate(@thread.issue) if @thread.issue
    @messages = @thread.messages.all
    @new_message = @thread.messages.build
    @subscribers = @thread.subscribers
    @library_items = Library::Item.find_by_tags_from(@thread).limit(5)
    @tag_panel = TagPanelDecorator.new(@thread, form_url: thread_tags_path(@thread))
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

  def subscribe_users(thread)
    subscribe_group_users(thread) if thread.group
    subscribe_issue_users(thread) if thread.issue
  end

  def subscribe_group_users(thread)
    members = thread.group.members.active.with_pref(:subscribe_new_group_thread)
    members.each{ |member| thread.subscriptions.create(user: member) unless member.subscribed_to_thread?(thread) }
  end

  def subscribe_issue_users(thread)
    buffered_location = thread.issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    locations = UserLocation.intersects(buffered_location).
        joins(:user => :prefs).
        where(user_prefs: {subscribe_new_user_location_issue_thread: true}).
        all

    locations.each{ |loc| thread.subscriptions.create(user: loc.user) unless loc.user.subscribed_to_thread?(thread) }
  end
end
