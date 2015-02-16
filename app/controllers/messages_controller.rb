class MessagesController < ApplicationController
  def create
    @thread = MessageThread.find(params[:thread_id])
    @message = @thread.messages.build(params[:message])
    @message.created_by = current_user

    if @message.save
      @thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(@thread)
      ThreadNotifier.notify_subscribers(@thread, :new_message, @message)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
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

  def show
    @thread = MessageThread.find(params[:thread_id])
    @message = @thread.messages.find(params[:id])

    redirect_to @message.component.file.url
  end
end
