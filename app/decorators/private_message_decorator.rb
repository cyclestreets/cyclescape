# frozen_string_literal: true

class PrivateMessageDecorator < ApplicationDecorator
  def other(current_user)
    current_user == object.created_by ? object.user : object.created_by
  end
end
