# frozen_string_literal: true

class Message::ActionsController < Message::BaseController
  protected

  def resource_class
    ActionMessage
  end

  def permit_params
    [:description]
  end
end

