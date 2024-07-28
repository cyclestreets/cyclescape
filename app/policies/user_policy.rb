# frozen_string_literal: true

class UserPolicy < GuestsAllowedPolicy
  def logged_in?
    @user
  end

  def view_full_name?
    application_view_full_name?(record)
  end

  def view_profile?
    application_view_profile?(record)
  end

  def send_private_message?
    private_message = MessageThread.new(user: record).tap(&:readonly!)
    user && Pundit.policy!(user, private_message).new?
  end

  def created_by_id
    record.id
  end
end
