class MessageThread::SubscriptionsController < MessageThread::BaseController
  filter_access_to :all, attribute_check: true, load_method: :load_thread

  def create
    if @thread.add_subscriber current_user
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path @thread
  end

  def destroy
    @subscription = @thread.subscriptions.find params[:id]
    @subscription.destroy
    set_flash_message :success
    redirect_to thread_path @thread
  end
end
