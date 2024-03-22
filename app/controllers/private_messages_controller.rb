# frozen_string_literal: true

class PrivateMessagesController < ApplicationController
  def index
    authorize User, :logged_in?

    count = if current_user
              MessageThread.unviewed_private_count(current_user)
            else
              0
            end
    render json: { count: count }
  end
end
