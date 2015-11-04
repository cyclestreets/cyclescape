class Message::BaseController < ApplicationController
  before_filter :thread
  before_filter :build_message, only: :create

  def create
    # Can't really check for spam with non-text messages
    message.check_reason = 'not_approved' unless current_user.approved?

    if message.save
      thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(thread)
      if message.check_reason
        flash[:alert] = t(message.check_reason)
      else
        message.skip_mod_queue!
        set_flash_message :success
      end
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  protected

  def thread
    # Need to check if user has access?
    @thread ||= MessageThread.find(params[:thread_id])
  end

  def message
    @message ||= thread.messages.build
  end

  def build_message
    message.created_by = current_user
    message.component = populate_component
  end

  def populate_component
    component.thread = thread
    component.message = message
    component.created_by = current_user
    component
  end
end
