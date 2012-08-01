# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_filter :load_group

  def index
    issue_threads = ThreadList.issue_threads_from_group(@group).paginate(page: params[:issue_threads_page])
    @issue_threads = ThreadListDecorator.decorate(issue_threads)

    general_threads = ThreadList.general_threads_from_group(@group).paginate(page: params[:general_threads_page])
    @general_threads = ThreadListDecorator.decorate(general_threads)
  end

  def new
    @thread = @group.threads.build({privacy: @group.default_thread_privacy})
    @message = @thread.messages.build
  end

  def create
    @thread = @group.threads.build(params[:thread])
    @thread.created_by = current_user
    @message = @thread.messages.build(params[:message])
    @message.created_by = current_user

    if @thread.save
      @thread.subscriptions.create({user: current_user}, without_protection: true)
      subscribe_users(@thread)
      ThreadNotifier.notify_subscribers(@thread, :new_message, @message)

      NewThreadNotifier.notify_new_thread(@thread)
      redirect_to group_thread_path(@group, @thread)
    else
      render :new
    end
  end

  protected

  def load_group
    @group = Group.find(params[:group_id] || current_group)
  end
end
