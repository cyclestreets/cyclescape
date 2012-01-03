class Message::PhotosController < Message::BaseController
  def create
    @message = @thread.messages.build(created_by: current_user)
    @photo = PhotoMessage.new(params[:photo_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @photo

    if @message.save
      ThreadNotifier.notify_subscribers(@thread, :new_photo_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  def show
    @photo = PhotoMessage.find(params[:id])
  end
end
