# frozen_string_literal: true

class Message::PollsController < ApplicationController
  before_action :poll_option

  def vote
    authorize User, :logged_in?
    authorize poll_option.poll_message.thread, :show?

    poll_option.poll_message.with_lock do
      poll_option.poll_message.poll_votes.where(user: current_user).destroy_all
      poll_option.poll_votes.find_or_create_by!(user: current_user)
    end
    render partial: "message/polls/show", locals: { component: poll_option.poll_message }
  end

  private

  def poll_option
    @poll_option ||= PollOption.find(params[:poll_vote][:poll_option_id])
  end
end
