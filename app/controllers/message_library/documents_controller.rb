# frozen_string_literal: true

class MessageLibrary::DocumentsController < Library::DocumentsController
  def new
    @document = Library::Document.new
    @document.title = message.component.title
    authorize @document
  end

  def create
    @document = Library::Document.new permitted_params
    @document.created_by = current_user
    @document.file = message.component.file
    authorize @document

    if @document.save
      redirect_to library_document_path @document
    else
      render :new
    end
  end

  protected

  def message
    @message ||= Message.find params[:message_id]
  end

  def permitted_params
    params.require(:library_document).permit :title, :file, :retained_file, :tags_string
  end
end
