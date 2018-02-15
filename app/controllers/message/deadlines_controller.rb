# frozen_string_literal: true

class Message::DeadlinesController < Message::BaseController
  protected

  def component
    @component ||= DeadlineMessage.new permitted_params
  end

  def permitted_params
    params.require(:deadline_message).permit :deadline, :title, :all_day
  end

end
