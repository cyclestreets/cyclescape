class Issue::MessageThreadsController < MessageThreadsController
  before_filter :load_issue
  skip_before_filter :load_thread

  def index
    threads = @issue.threads.order_by_latest_message.page params[:page]
    @threads = ThreadListDecorator.decorate_collection threads
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
    @thread = @issue.threads.build permitted_params.merge(created_by: current_user, tags: @issue.tags)
    @message = thread.messages.build permitted_message_params.merge(created_by: current_user)
    thread.check_reason = if @thread.spam?
                            t('.possible_spam')
                          elsif !current_user.approved?
                            t('.not_approved')
                          end
    saved = thread.save
    if thread.check_reason && saved
      thread.check!
      flash[:alert] = thread.check_reason
      redirect_to home_path
    elsif saved
      thread.subscriptions.create( user: current_user ) unless current_user.subscribed_to_thread?(thread)
      subscribe_and_notify
      redirect_to thread_path thread
    else
      @available_groups = current_user.groups
      render :new
    end

  end

  protected

  def subscribe_and_notify
    ThreadSubscriber.subscribe_users thread
    ThreadNotifier.notify_subscribers thread, :new_message, thread.messages.first

    NewThreadNotifier.notify_new_thread thread
  end

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
