class Message::Library::NotesController < Library::NotesController
  def new
    @message = Message.find(params[:message_id])
    @note = Library::Note.new
    @note.body = @message.body
  end
end
