class MessagesController < ApplicationController
  def create
    logger.debug(debug_msg("MessagesController#create debugging"))
    logger.debug(debug_msg("Finding thread..."))
    @thread = MessageThread.find(params[:thread_id])
    logger.debug(debug_msg("Building message..."))
    @message = @thread.messages.build(params[:message])
    logger.debug(debug_msg("Assigning user..."))
    @message.created_by = current_user

    logger.debug(debug_msg("Saving message..."))
    if @message.save
      logger.debug(debug_msg("Adding subscriber..."))
      @thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(@thread)
      logger.debug(debug_msg("notifying subscribers..."))
      ThreadNotifier.notify_subscribers(@thread, :new_message, @message)
      logger.debug(debug_msg("setting flash message..."))
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    logger.debug(debug_msg("redirecting..."))
    redirect_to thread_path(@thread)
  end

  def censor
    @thread = MessageThread.find(params[:thread_id])
    @message = @thread.messages.find(params[:id])

    if @message.censor!
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
