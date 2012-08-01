class Issue::MessageThreadsController < MessageThreadsController
  before_filter :load_issue

  def index
    @threads = @issue.threads
  end

  def new
    @thread = @issue.threads.build
    if current_group
      @thread.group = current_group
      @thread.privacy = current_group.default_thread_privacy
    end
    @message = @thread.messages.build
    @available_groups = current_user.groups
  end

  def create
    @thread = @issue.threads.build(params[:thread])
    @thread.created_by = current_user
    @message = @thread.messages.build(params[:message])
    @message.created_by = current_user

    if @thread.save
      @thread.subscriptions.create(user: current_user)
      subscribe_users(@thread)
      ThreadNotifier.notify_subscribers(@thread, :new_message, @message)

      NewThreadNotifier.notify_new_thread(@thread)
      redirect_to issue_thread_path(@issue, @thread)
    else
      @available_groups = current_user.groups
      render :new
    end
  end

  protected

  def load_issue
    @issue = Issue.find(params[:issue_id])
  end
end
