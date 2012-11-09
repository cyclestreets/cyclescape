class Message::LibraryItemsController < Message::BaseController
  def create
    @message = @thread.messages.build(params[:message])
    @message.created_by = current_user

    @library_item = LibraryItemMessage.new(params[:library_item_message])
    @library_item.thread = @thread
    @library_item.message = @message
    @library_item.created_by = current_user

    @message.component = @library_item

    if @message.save
      @thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(@thread)
      ThreadNotifier.notify_subscribers(@thread, :new_library_item_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
