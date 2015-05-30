class Message::LibraryItemsController < Message::BaseController
  # NB I can't see if this is cntrl is actually used...
  protected

  def component
    @library_item ||= LibraryItemMessage.new permitted_params
  end

  def notification_name
    :new_library_item_message
  end

  def permitted_params
    params.require(:library_item_message).permit :library_item_id
  end
end
