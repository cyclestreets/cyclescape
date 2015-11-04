class Message::DeadlinesController < Message::BaseController
  protected

  def component
    @deadline ||= DeadlineMessage.new permitted_params
  end

  def permitted_params
    params.require(:deadline_message).permit :deadline, :title
  end

end
