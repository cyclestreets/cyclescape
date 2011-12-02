class Message::LinksController < Message::BaseController
  def create
    @message = @thread.messages.build(created_by: current_user)
    @link = LinkMessage.new(params[:link_message].merge({
        thread: @thread,
        message: @message,
        created_by: current_user}))
    @message.component = @link

    if @message.save
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
