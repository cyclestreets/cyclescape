class MessageThread::SubscriptionsController < MessageThread::BaseController
  filter_access_to :all, attribute_check: true, load_method: :load_thread

  def create
    respond_to do |format|
      if  @thread.add_subscriber current_user
        set_flash_message :success
      else
        set_flash_message :failure
      end
      format.html { redirect_to thread_path @thread }
      format.js   { }
    end
  end

  def destroy
    @subscription = @thread.subscriptions.find params[:id]
    @subscription.destroy
    respond_to do |format|
      set_flash_message :success
      format.html { redirect_to thread_path @thread }
      format.js { }
    end
  end
end
