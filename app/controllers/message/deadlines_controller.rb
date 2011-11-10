class Message::DeadlinesController < Message::BaseController
  def create
    @message = @thread.messages.build(params[:message].merge({created_by: current_user}))
    @deadline = DeadlineMessage.new(params[:deadline_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @deadline

    if @message.save
      flash.notice = "Deadline created."
    else
      flash.alert = "Deadline could not be created."
    end
    redirect_to thread_path(@thread)
  end
end
