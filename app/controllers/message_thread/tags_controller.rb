class MessageThread::TagsController < MessageThread::BaseController
  def update
    if @thread.update_attributes(tags_string: params[:message_thread][:tags_string])
      render partial: "panel", locals: {thread: @thread}
    else
      head :conflict
    end
  end
end
