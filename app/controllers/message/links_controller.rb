class Message::LinksController < Message::BaseController
  def create
    @message = @thread.messages.build
    @message.created_by = current_user

    @link = LinkMessage.new(params[:link_message])
    @link.thread = @thread
    @link.message = @message
    @link.created_by = current_user

    @message.component = @link

    if @message.save
      ThreadNotifier.notify_subscribers(@thread, :new_link_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
