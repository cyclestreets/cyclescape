class MessageThread::SubscriptionsController < MessageThread::BaseController
  def create
    @subscription = @thread.subscriptions.build(user: current_user)
    if @subscription.save
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
