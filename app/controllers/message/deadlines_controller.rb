class Message::DeadlinesController < Message::BaseController
  protected

  def component
    @deadline ||= DeadlineMessage.new(params[:deadline_message])
  end

  def notification_name
    :new_deadline_message
  end
end
