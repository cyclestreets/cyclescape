# frozen_string_literal: true

class Message::PollsController < ApplicationController
  before_action :poll_option
  filter_access_to :all, attribute_check: true, model: PollOption

  def vote
    poll_option.poll_message.with_lock do
      poll_option.poll_message.poll_votes.where(user: current_user).destroy_all
      poll_option.poll_votes.find_or_create_by!(user: current_user)
    end
  end

  private

  def poll_option
    @poll_option ||= PollOption.find(params[:poll_vote][:poll_option_id])
  end
end
