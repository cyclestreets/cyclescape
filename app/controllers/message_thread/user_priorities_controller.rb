# frozen_string_literal: true

class MessageThread::UserPrioritiesController < MessageThread::BaseController
  respond_to :json

  def update
    utp = @thread.priority_for(current_user) || @thread.user_priorities.build
    utp.user = current_user

    @flash = if utp.update permitted_params
               {notice: t('.success')}
             else
               {alert: t('.failure')}
             end
  end

  private

  def permitted_params
    params.require(:user_thread_priority).permit :priority
  end

end
