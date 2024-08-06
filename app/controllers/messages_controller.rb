# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :build_message, only: :create

  def create
    message.check_reason = check_reason unless thread.private_message?

    message.components.each do |component|
      component.assign_attributes(created_by: current_user, thread: thread)
    end

    if message.save
      if message.check_reason
        flash[:alert] = t(message.check_reason)
      else
        message.skip_mod_queue!
        set_flash_message :success
      end
    else
      flash[:alert] = message.errors.to_a.to_sentence
    end

    ThreadRecorder.thread_viewed thread, current_user

    respond_to do |format|
      format.html { redirect_to thread_path(thread) }
      format.js { render "messages/created" }
    end
  end

  def censor
    authorize message

    if message.censor!
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path thread
  end

  def approve
    authorize message

    message.approve!
  end

  def reject
    authorize message

    message.reject!
  end

  def vote_up
    authorize message

    current_user.with_lock do
      current_user.vote_exclusively_for message unless current_user.voted_for? message
    end
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  def vote_clear
    authorize message

    current_user.clear_votes message
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  protected

  def build_message
    @message = thread.messages.build permitted_params.merge(created_by: current_user)
    authorize @message
    @message
  end

  def check_reason
    # spam? check needs to be done in the controller
    if message.spam?
      "possible_spam"
    elsif !current_user.approved?
      "not_approved"
    end
  end

  def permitted_params
    params.require(:message).permit(
      :body,
      completing_action_message_ids: [],
      action_messages_attributes: [:description],
      cyclestreets_photo_messages_attributes: %i[photo_url caption cyclestreets_id icon_properties loc_json],
      deadline_messages_attributes: %i[deadline title all_day],
      document_messages_attributes: %i[title file retained_file],
      link_messages_attributes: %i[url title description],
      map_messages_attributes: %i[caption loc_json],
      photo_messages_attributes: %i[base64_photo retained_photo caption],
      street_view_messages_attributes: %i[caption heading pitch location_string],
      thread_leader_messages_attributes: %i[description unleading_id],
      poll_messages_attributes: [:question, poll_options_attributes: [:option]]
    )
  end

  def message
    @message ||= Message.includes(:thread).find(params[:id])
  end

  def thread
    @thread ||= MessageThread.find(params[:thread_id])
  end
end
