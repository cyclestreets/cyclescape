class Message::LinksController < Message::BaseController
  protected

  def component
    @link ||= LinkMessage.new permitted_params
  end

  def notification_name
    :new_link_message
  end

  def permitted_params
    params.require(:link_message).permit :url, :title, :description
  end
end
