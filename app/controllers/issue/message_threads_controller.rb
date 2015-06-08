class Issue::MessageThreadsController < MessageThreadsController
  before_filter :load_issue
  skip_before_filter :load_thread

  def index
    threads = @issue.threads.order_by_latest_message.page params[:page]
    @threads = ThreadListDecorator.decorate threads
  end

  def new
    @thread = @issue.threads.build
    if current_group
      @thread.group = current_group
      @thread.privacy = current_group.default_thread_privacy
    end
    @message = @thread.messages.build
    @message.body = @issue.description if @issue.threads.count == 0
    @available_groups = current_user.groups
  end

  def create
    @thread = @issue.threads.build permitted_params
    @thread.created_by = current_user
    @thread.tags = @issue.tags
    @message = @thread.messages.build permitted_message_params
    @message.created_by = current_user

    if @thread.save
      @thread.subscriptions.create({ user: current_user }, without_protection: true) unless current_user.subscribed_to_thread?(@thread)
      ThreadSubscriber.subscribe_users @thread
      ThreadNotifier.notify_subscribers @thread, :new_message, @message

      NewThreadNotifier.notify_new_thread @thread
      redirect_to thread_path @thread
    else
      @available_groups = current_user.groups
      render :new
    end
  end

  protected

  def load_issue
    @issue = Issue.find params[:issue_id]
  end

  def permitted_issue_params
    params.require(:issue).permit :title, :description, :loc_json, :photo, :retained_photo, :tags_string
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end
end
