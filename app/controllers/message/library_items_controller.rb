class Message::LibraryItemsController < Message::BaseController
  def create
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))
    @library_item = LibraryItemMessage.new(params[:library_item_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @library_item

    if @message.save
      ThreadNotifier.notify_subscribers(@thread, :new_library_item_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
