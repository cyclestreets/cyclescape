class Message::DocumentsController < Message::BaseController
  def create
    @message = @thread.messages.build
    @message.created_by = current_user

    @document = DocumentMessage.new(params[:document_message])
    @document.thread = @thread
    @document.message = @message
    @document.created_by = current_user

    @message.component = @document

    if @message.save
      ThreadNotifier.notify_subscribers(@thread, :new_document_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  def show
    @document = DocumentMessage.find(params[:id])
  end
end
