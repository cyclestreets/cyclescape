class Message::LibraryItemsController < Message::BaseController
  # NB I can't see if this is cntrl is actually used...
  protected

  def component
    @library_item ||= LibraryItemMessage.new permitted_params
  end

  def permitted_params
    params.require(:library_item_message).permit :library_item_id
  end

  def message
    @message ||= thread.messages.build permitted_message_params
  end

  def permitted_message_params
    params.require(:message).permit :body
  end
end
