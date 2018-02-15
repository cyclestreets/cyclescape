class Message::DocumentsController < Message::BaseController
  def show
    @document = DocumentMessage.find params[:id]
  end

  protected

  def component
    @component ||= DocumentMessage.new permitted_params
  end

  def permitted_params
    params.require(:document_message).permit :title, :file, :retained_file
  end
end
