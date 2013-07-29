class Message::DeadlinesController < Message::BaseController
  def create
    @message = @thread.messages.build
    @message.created_by = current_user

    @deadline = DeadlineMessage.new(params[:deadline_message])
    @deadline.thread = @thread
    @deadline.message = @message
    @deadline.created_by = current_user

    @message.component = @deadline

    if @message.save
      @thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(@thread)
      ThreadNotifier.notify_subscribers(@thread, :new_deadline_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
