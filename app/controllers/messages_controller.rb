# frozen_string_literal: true

class MessagesController < ApplicationController
  filter_access_to :approve, :reject, attribute_check: true
  protect_from_forgery except: :vote_detail

  def create
    @message ||= thread.messages.build permitted_params.merge(created_by: current_user)

    message.check_reason = check_reason

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
      format.js { render 'messages/created' }
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
    unless current_user.voted_for? message
      current_user.vote_exclusively_for message
    end
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  def vote_clear
    current_user.clear_votes message
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  def vote_detail
    render partial: "shared/vote_detail", locals: { resource: message }
  end

  protected

  def check_reason
    # spam? check needs to be done in the controller
    if message.spam?
      'possible_spam'
    elsif !current_user.approved?
      'not_approved'
    end
  end

  def permitted_params
    params.require(:message).permit :body, :component, action_message_ids: []
  end

  def message
    @message ||= Message.includes(:thread).find(params[:id])
  end

  def thread
    @thread ||= MessageThread.find(params[:thread_id])
  end
end
