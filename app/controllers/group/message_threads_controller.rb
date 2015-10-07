# Note inheritance
class Group::MessageThreadsController < MessageThreadsController
  before_filter :load_group

  def index
    set_page_title t('group.message_threads.index.title', group: @group.name)

    issue_threads = ThreadList.issue_threads_from_group(@group).paginate(page: params[:issue_threads_page])
    @issue_threads = ThreadListDecorator.decorate_collection issue_threads

    general_threads = ThreadList.general_threads_from_group(@group).paginate(page: params[:general_threads_page])
    @general_threads = ThreadListDecorator.decorate_collection general_threads
  end

  def new
    @thread = @group.threads.build privacy: @group.default_thread_privacy
    @message = @thread.messages.build
  end

  def create
    @thread = @group.threads.build permitted_params
    @thread.created_by = current_user
    @message = @thread.messages.build permitted_message_params
    @message.created_by = current_user

    if @thread.save

      @thread.subscriptions.create( user: current_user ) unless current_user.subscribed_to_thread?(@thread)
      ThreadSubscriber.subscribe_users @thread
      ThreadNotifier.notify_subscribers(@thread, :new_message, @message)

      NewThreadNotifier.notify_new_thread @thread
      redirect_to thread_path @thread
    else
      render :new
    end
  end

  protected

  def load_group
    @group = Group.find_by(id: params[:group_id]) || current_group
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end

end
