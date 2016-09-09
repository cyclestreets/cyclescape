class MessageThread::LeadersController < MessageThread::BaseController
  filter_access_to :all, attribute_check: true, load_method: :load_thread

  def create
    if @thread.leaders << current_user
      set_flash_message :success
      ThreadNotifier.notify_subscribers_event @thread, :new_leader, current_user
    else
      flash[:alert] = I18n.t(:failure)
    end

    respond_to do |format|
      format.html { redirect_to thread_path @thread }
      format.js   { }
    end
  end

  def destroy
    if @thread.thread_leaders.find_by(user: current_user).try(:destroy)
      set_flash_message :success
      ThreadNotifier.notify_subscribers_event @thread, :removed_leader, current_user
    else
      flash[:alert] = I18n.t(:failure)
    end

    respond_to do |format|
      format.html { redirect_to thread_path @thread }
      format.js { }
    end
  end
end
