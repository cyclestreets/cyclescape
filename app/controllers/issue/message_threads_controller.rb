class Issue::MessageThreadsController < MessageThreadsController
  def index
    threads = issue.threads.order_by_latest_message.page params[:page]
    @threads = ThreadListDecorator.decorate_collection threads
  end

  def new
    @thread = issue.threads.build
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
    @message = thread.messages.build permitted_message_params.merge(created_by: current_user)

    # spam? check needs to be done in the controller
    @message.check_reason = if @message.spam?
                            'possible_spam'
                          elsif !current_user.approved?
                            'not_approved'
                          end
    if thread.save
      thread.subscriptions.create( user: current_user ) unless current_user.subscribed_to_thread?(thread)
      if @message.check_reason
        flash[:alert] = t(@message.check_reason)
      else
        @message.skip_mod_queue!
      end
      redirect_to thread_path thread
    else
      @available_groups = current_user.groups
      render :new
    end
  end

  protected

  def issue
    @issue ||= Issue.find params[:issue_id]
  end

  def permitted_issue_params
    params.require(:issue).permit :title, :description, :loc_json, :photo, :retained_photo, :tags_string
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end
end
