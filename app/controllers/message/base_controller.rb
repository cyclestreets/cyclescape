# frozen_string_literal: true

class Message::BaseController < ApplicationController
  before_filter :thread
  before_filter :build_message, only: :create

  def create
    # Can't really check for spam with non-text messages
    message.check_reason = 'not_approved' unless current_user.approved?

    if message.save
      thread.add_subscriber(current_user) unless current_user.ever_subscribed_to_thread?(thread)
      if message.check_reason
        flash[:alert] = t(message.check_reason)
      else
        message.skip_mod_queue!
        set_flash_message :success
      end
    else
      set_flash_message(:failure)
    end
    redirect_to thread_path(@thread)
  end

  protected

  def thread
    # Need to check if user has access?
    @thread ||= MessageThread.find(params[:thread_id])
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
