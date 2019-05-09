# frozen_string_literal: true

class Message::LibraryItemsController < Message::BaseController
  # NB I can't see if this is cntrl is actually used...

  protected

  def resource_class
    LibraryItemMessage
  end

  def permit_params
    [:library_item_id]
  end

  def message
    @message ||= thread.messages.build permitted_message_params
  end

  def permitted_message_params
    params.require(:message).permit :body
  end
end
