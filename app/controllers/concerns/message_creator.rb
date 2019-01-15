module MessageCreator
  private

  def redirect_on_check_reason(message, spam_path:, clean_path:)
    if message.check_reason
      flash[:alert] = t(message.check_reason)
      redirect_to spam_path
    else
      message.skip_mod_queue!
      redirect_to clean_path
    end
  end

  def create_message(thread)
    message = thread.messages.build permitted_message_params.merge(created_by: current_user)

    # spam? check needs to be done in the controller
    message.check_reason = if message.spam?
                              'possible_spam'
                            elsif !current_user.approved?
                              'not_approved'
                            end
    message
  end

  def permitted_message_params
    params.require(:message).permit :body, :component
  end
end
