class Message::PhotosController < Message::BaseController
  def create
    @message = @thread.messages.build
    @message.created_by = current_user

    @photo = PhotoMessage.new(params[:photo_message])
    @photo.thread = @thread
    @photo.message = @message
    @photo.created_by = current_user

    @message.component = @photo

    if @message.save
      @thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(@thread)
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
