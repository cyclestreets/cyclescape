# frozen_string_literal: true

class MessageThread::UserPrioritiesController < MessageThread::BaseController
  respond_to :json

  def update
    utp = @thread.priority_for(current_user)

    if utp.update permitted_params
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end
  end

  private

  def permitted_params
    params.require(:user_thread_priority).permit :priority
  end
end
