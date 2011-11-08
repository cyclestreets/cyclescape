class Message::LinksController < ApplicationController
  before_filter :load_thread

  def create
    @message = @thread.messages.build(params[:message].merge({created_by: current_user}))
    @link = LinkMessage.new(params[:link_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @link

    if @message.save
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  protected

  def load_thread
    # Need to check if user has access?
    @thread = MessageThread.find(params[:thread_id])
  end
end
