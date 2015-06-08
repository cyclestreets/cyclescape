class MessageThread::UserPrioritiesController < MessageThread::BaseController
  def create
    utp = @thread.user_priorities.build
    utp.user = current_user

    if utp.update_attributes permitted_params
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path @thread
  end

  def update
    utp = @thread.priority_for current_user

    if utp.update_attributes permitted_params
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path @thread
  end

  private

  def permitted_params
    params.require(:user_thread_priority).permit :priority
  end

end
