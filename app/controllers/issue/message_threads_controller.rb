class Issue::MessageThreadsController < MessageThreadsController
  def index
    threads = issue.threads.order_by_latest_message.page params[:page]
    @unviewed_thread_ids = threads.unviewed_for(current_user).ids.uniq
    @threads = ThreadListDecorator.decorate_collection threads
  end

  def new
    @thread = issue.threads.build
    set_page_title nil, issue: issue.title
    if current_group
      @thread.group = current_group
      @thread.privacy = current_group.default_thread_privacy
    end
    @message = @thread.messages.build
    @message.body = issue.description if issue.threads.count == 0
    @available_groups = current_user.groups
  end

  def create
    @thread = issue.threads.build permitted_params.merge(created_by: current_user, tags: issue.tags)
    super
  end

  protected

  def issue
    @issue ||= Issue.find params[:issue_id]
  end

end
