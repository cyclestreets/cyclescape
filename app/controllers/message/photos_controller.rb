class Message::PhotosController < Message::BaseController
  def create
    @message = @thread.messages.build(params[:message].merge({created_by: current_user}))
    @photo = PhotoMessage.new(params[:photo_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @photo

    if @message.save
      flash.notice = "Photo uploaded."
    else
      flash.alert = "Could not create photo message."
    end
    redirect_to thread_path(@thread)
  end
end
