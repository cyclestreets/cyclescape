class Group::MessageThreadsController < MessageThreadsController
  before_filter :load_group

  def index
    @threads = @group.threads
  end

  def new
    @thread = @group.threads.build
    @message = @thread.messages.build
  end

  def create
    @thread = @group.threads.build(params[:thread].merge(created_by: current_user))
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @thread.save
      redirect_to group_thread_path(@group, @thread)
    else
      render :new
    end
  end

  protected

  def load_group
    @group = Group.find(params[:group_id])
  end

  def load_thread
    @thread = @group.threads.find(params[:id])
  end
end
