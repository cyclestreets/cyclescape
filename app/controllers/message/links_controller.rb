# frozen_string_literal: true

class Message::LinksController < Message::BaseController
  protected

  def resource_class
    LinkMessage
  end

  def permit_params
    [:url, :title, :description]
  end
end
