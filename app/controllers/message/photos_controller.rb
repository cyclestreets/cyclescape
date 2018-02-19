class Message::PhotosController < Message::BaseController
  def show
    @photo = PhotoMessage.find params[:id]
  end

  protected

  def component
    @component ||= PhotoMessage.new permitted_params
  end

  def permitted_params
    params.require(:photo_message).permit :photo, :retained_photo, :caption
  end
end
