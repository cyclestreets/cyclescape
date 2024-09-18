# frozen_string_literal: true

class MessageLibrary::NotesController < Library::NotesController
  def new
    @message = Message.find(params[:message_id])
    @note = Library::Note.new
    @note.body = @message.body
    @start_location = current_user.start_location
    authorize @note
  end
end
