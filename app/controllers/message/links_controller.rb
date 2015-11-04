class Message::LinksController < Message::BaseController
  protected

  def component
    @link ||= LinkMessage.new permitted_params
  end

  def permitted_params
    params.require(:link_message).permit :url, :title, :description
  end
end
