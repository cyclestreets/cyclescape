# frozen_string_literal: true

class Message::LibraryItemsController < MessagesController
  filter_access_to :create, attribute_check: true, model: LibraryItemMessage, load_method: :build_library_item_message
  def create
    super
  end

  protected

  def permitted_message_params
    params.require(:message).permit :body
  end

  def permitted_params
    params.require(:library_item_message).permit :library_item_id
  end

  def build_message
    @message ||= thread.messages.build permitted_message_params.merge(created_by: current_user)
  end

  def build_library_item_message
    @library_item_message ||= @message.library_item_messages.build(permitted_params).tap { |lim| lim.thread = thread }
  end
end
