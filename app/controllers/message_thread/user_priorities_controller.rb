class MessageThread::UserPrioritiesController < MessageThread::BaseController
  def create
    utp = @thread.user_priorities.build
    utp.user = current_user

    if utp.update_attributes(params[:user_thread_priority])
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  def update
    utp = @thread.priority_for(current_user)

    if utp.update_attributes(params[:user_thread_priority])
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end
end
