class Message::LinksController < Message::BaseController
  protected

  def component
    @link ||= LinkMessage.new(params[:link_message])
  end

  def notification_name
    :new_link_message
  end
end
