class PrivateMessageDecorator < ApplicationDecorator
  def other(current_user)
    current_user == source.created_by ? source.user : source.created_by
  end
end
