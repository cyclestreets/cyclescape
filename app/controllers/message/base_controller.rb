# frozen_string_literal: true

class Message::BaseController < MessagesController
  before_filter :thread
  before_filter :build_message, only: :create

  def create
    # Can't really check for spam with non-text messages
    message.check_reason = 'not_approved' unless current_user.approved?

    super
  end

  protected

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
