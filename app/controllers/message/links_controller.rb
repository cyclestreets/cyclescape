# frozen_string_literal: true

class Message::LinksController < Message::BaseController
  protected

  def component
    @component ||= LinkMessage.new permitted_params
  end

  def permitted_params
    params.require(:link_message).permit :url, :title, :description
  end
end
