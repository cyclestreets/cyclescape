class MessagesController < ApplicationController
  def create
    @thread = MessageThread.find(params[:thread_id])
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @message.save
      redirect_to :back
    else
      raise "Invalid message"
    end
  end
end
