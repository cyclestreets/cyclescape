class Message::PhotosController < Message::BaseController
  def create
    @message = @thread.messages.build(created_by: current_user)
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
end
