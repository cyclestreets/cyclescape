class MessageThread::SubscriptionsController < MessageThread::BaseController
  def create
    if @thread.add_subscriber(current_user)
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  def destroy
    @subscription = @thread.subscriptions.find(params[:id])
    @subscription.destroy
    set_flash_message(:success)
    redirect_to thread_path(@thread)
  end
end
