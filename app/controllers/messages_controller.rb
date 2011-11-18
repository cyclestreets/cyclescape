class MessagesController < ApplicationController
  def create
    @thread = MessageThread.find(params[:thread_id])
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @message.save
      @thread.subscribers.each do |sub|
        ThreadMailer.new_message(@message, sub).deliver
      end
      redirect_to :back
    else
      raise "Invalid message"
    end
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
