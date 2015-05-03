class Message::DocumentsController < Message::BaseController
  def show
    @document = DocumentMessage.find(params[:id])
  end

  protected

  def component
    @document ||= DocumentMessage.new(params[:document_message])
  end

  def notification_name
    :new_document_message
  end
end
