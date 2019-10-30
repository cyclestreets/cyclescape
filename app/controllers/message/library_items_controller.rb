# frozen_string_literal: true

class Message::LibraryItemsController < MessagesController
  def create
    @message = thread.messages.build permitted_message_params.merge(created_by: current_user)
    @message.library_item_messages.build(permitted_params)
    super
  end

  protected

  def permitted_message_params
    params.require(:message).permit :body
  end

  def permitted_params
    params.require(:library_item_message).permit :library_item_id
  end
end
