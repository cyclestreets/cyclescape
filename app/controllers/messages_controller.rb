class MessagesController < ApplicationController
  filter_access_to :approve, :reject, attribute_check: true

  def create
    @message = thread.messages.build permitted_params.merge(created_by: current_user)

    # spam? check needs to be done in the controller
    message.check_reason = if message.spam?
                            'possible_spam'
                          elsif !current_user.approved?
                            'not_approved'
                          end

    if message.save
      if message.check_reason
        flash[:alert] = t(message.check_reason)
      else
        message.skip_mod_queue!
        set_flash_message :success
      end
    else
      set_flash_message :failure
    end
    redirect_to thread_path thread
  end

  def censor
    if message.censor!
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path thread
  end

  def approve
    message.approve!
  end

  def reject
    message.reject!
  end

  protected

  def permitted_params
    params.require(:message).permit :body, :component
  end

  def message
    @message ||= Message.includes(:thread).find(params[:id])
  end

  def thread
    @thread ||= MessageThread.find(params[:thread_id])
  end

end
