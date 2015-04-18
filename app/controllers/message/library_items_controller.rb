class Message::LibraryItemsController < Message::BaseController
  protected

  def component
    @library_item ||= LibraryItemMessage.new(params[:library_item_message])
  end

  def notification_name
    :new_library_item_message
  end
end
