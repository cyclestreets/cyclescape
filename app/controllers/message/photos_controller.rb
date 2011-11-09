class Message::PhotosController < ApplicationController
  before_filter :load_thread

  def create
    @message = @thread.messages.build(params[:message].merge({created_by: current_user}))
    @photo = PhotoMessage.new(params[:photo_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @photo

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
