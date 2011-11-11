class Issue::MessageThreadsController < MessageThreadsController
  before_filter :load_group
  before_filter :load_issue

  def index
    @threads = @issue.threads
  end

  def new
    @thread = @issue.threads.build
    @thread.privacy = @group.default_thread_privacy if @group
    @message = @thread.messages.build
  end

  def create
    @thread = @issue.threads.build(params[:thread].merge(created_by: current_user))
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @thread.save
      redirect_to issue_thread_path(@issue, @thread)
    else
      render :new
    end
  end

  protected

  def load_issue
    @issue = Issue.find(params[:issue_id])
  end

  def load_group
    if params[:group_id]
      @group = current_user.groups.find(params[:group_id])
    end
  end
end
