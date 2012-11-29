class MessageLibrary::DocumentsController < Library::DocumentsController
  def new
    @message = Message.find(params[:message_id])
    @document = Library::Document.new
    @document.title = @message.component.title
  end

  def create
    @message = Message.find(params[:message_id])
    @document = Library::Document.new(params[:library_document])
    @document.created_by = current_user
    @document.file = @message.component.file

    if @document.save
      redirect_to library_document_path(@document)
    else
      render :new
    end
  end
end
