class Message::PhotosController < Message::BaseController
  def show
    @photo = PhotoMessage.find(params[:id])
  end

  protected

  def component
    @photo ||= PhotoMessage.new(params[:photo_message])
  end

  def notification_name
    :new_photo_message
  end
end
