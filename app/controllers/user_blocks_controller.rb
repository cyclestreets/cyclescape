# frozen_string_literal: true

class UserBlocksController < ApplicationController
  def create
    authorize User, :logged_in?

    current_user.blocked_user_ids |= [blocked_user_id]
    redirect_to(:back)
  end

  def destroy
    authorize User, :logged_in?

    current_user.user_blocks.find_by(blocked_id: blocked_user_id).destroy
    redirect_to(:back)
  end

  private

  def blocked_user_id
    params[:user_block][:blocked_id].to_i
  end
end
