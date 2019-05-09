# frozen_string_literal: true

class Message::BaseController < MessagesController
  before_action :thread
  before_action :build_message, only: :create

  protected

  def check_reason
    # Can't really check for spam with non-text messages
    "not_approved" unless current_user.approved?
  end

  def message
    @message ||= thread.messages.build
  end

  def component
    @component ||= resource_class.new permitted_params
  end

  def permitted_params
    params.require(required_param).permit(permit_params)
  end

  def required_param
    resource_class.model_name.singular.to_sym
  end

  def build_message
    message.created_by = current_user
    message.component = populate_component
  end

  def populate_component
    component.thread = thread
    component.message = message
    component.created_by = current_user
    component.action_message_ids = params[required_param][:action_message_ids]
    component
  end
end
