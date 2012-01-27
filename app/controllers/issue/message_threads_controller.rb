class Issue::MessageThreadsController < MessageThreadsController
  before_filter :load_issue

  def index
    @threads = @issue.threads
  end

  def new
    @thread = @issue.threads.build
    @message = @thread.messages.build
    @available_groups = current_user.groups
  end

  def create
    @thread = @issue.threads.build(params[:thread].merge(created_by: current_user))
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @thread.save
      @thread.subscriptions.create(user: current_user)
      UserNotifier.notify_new_thread(@thread)
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
