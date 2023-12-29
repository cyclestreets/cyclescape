# frozen_string_literal: true

class MessageThread::SubscriptionsController < MessageThread::BaseController
  skip_before_action :load_thread
  before_action :load_subscription

  def edit
    skip_authorization # done via current_user
  end

  def create
    skip_authorization

    respond_to do |format|
      if @thread.add_subscriber current_user
        set_flash_message :success
      else
        set_flash_message :failure
      end
      format.html { redirect_to thread_path @thread }
      format.js   {}
    end
  end

  def destroy
    skip_authorization # done via current_user

    @subscription.destroy
    respond_to do |format|
      set_flash_message :success
      format.html do
        if params[:t]
          redirect_to root_path
        else
          redirect_to thread_path @thread
        end
      end
      format.js {}
    end
  end

  def current_user
    @user_by_token ||= User.find_by(public_token: params[:t]) || super
  end

  private

  def load_subscription
    subscriptions = load_thread.subscriptions
    @subscription = if params[:id]
                      subscriptions.where(user: current_user).find params[:id]
                    else
                      subscriptions.build
                    end
  end
end
