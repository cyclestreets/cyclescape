# frozen_string_literal: true

class Message::LibraryItemsController < MessagesController
  before_action :build_message, only: :create

  def create
    @message.library_item_messages.build(permitted_params).tap { |lim| lim.thread = thread }
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
    authorize @message
    @message
  end
end
