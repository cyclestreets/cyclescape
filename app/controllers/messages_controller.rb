# frozen_string_literal: true

class MessagesController < ApplicationController
  filter_access_to :approve, :reject, :censor, attribute_check: true

  def create
    @message ||= thread.messages.build permitted_params.merge(created_by: current_user)
    return redirect_to(:back) if thread.private_message? && !(permitted_to? :send_private_message, thread.other_user(current_user))

    message.check_reason = check_reason unless thread.private_message?

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
    if message.censor!
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to thread_path thread
  end

  def approve
    message.approve!
  end

  def reject
    message.reject!
  end

  def vote_up
    current_user.vote_exclusively_for message unless current_user.voted_for? message
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  def vote_clear
    current_user.clear_votes message
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  protected

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
      :body, :component,
      action_message_ids: [],
      actions_attributes: [:description],
      cyclestreets_photo_messages_attributes: %i[photo_url caption cyclestreets_id icon_properties loc_json],
      deadlines_attributes: %i[deadline title all_day],
      documents_attributes: %i[title file retained_file],
      library_item_messages_attributes: [:library_item_id],
      map_messages_attributes: %i[caption loc_json],
      photo_messages_attributes: %i[base64_photo retained_photo caption],
      street_view_messages_attributes: %i[caption heading pitch],
      thread_leader_messages_attributes: %i[description unleading_id]
    )
  end

  def message
    @message ||= Message.includes(:thread).find(params[:id])
  end

  def thread
    @thread ||= MessageThread.find(params[:thread_id])
  end
end
