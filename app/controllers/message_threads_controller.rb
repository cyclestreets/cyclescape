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
    # If it's an "administrative" discussion, don't subscribe without extra pref
    t = UserPref.arel_table
    pref = t[:involve_my_groups].eq("subscribe")
    constraint = thread.issue ? pref : pref.and(t[:involve_my_groups_admin].eq(true))
    members = thread.group.members.active.joins(:prefs).where(constraint)
    members.each do |member|
      if Authorization::Engine.instance.permit? :show, { object: thread, user: member }
        thread.subscriptions.create(user: member) unless member.subscribed_to_thread?(thread)
      end
    end
  end

  def subscribe_issue_users(thread)
    buffered_location = thread.issue.location.buffer(Geo::USER_LOCATIONS_BUFFER)

    locations = UserLocation.intersects(buffered_location).
        joins(:user => :prefs).
        where(user_prefs: {involve_my_locations: "subscribe"}).
        all

    locations.each do |loc|
      if Authorization::Engine.instance.permit? :show, { object: thread, user: loc.user }
        thread.subscriptions.create(user: loc.user) unless loc.user.subscribed_to_thread?(thread)
      end
    end
  end
end
