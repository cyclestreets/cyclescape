class MessageThread::SubscriptionsController < ApplicationController
  before_filter :load_thread

  def create
    @subscription = @thread.subscriptions.build(user: current_user)
    if @subscription.save
      Notifications.thread_subscribed(@subscription).deliver
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  protected

  def load_thread
    @thread = MessageThread.find(params[:thread_id])
  end
end
