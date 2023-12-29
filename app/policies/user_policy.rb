# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def view_full_name?
    super(record)
  end

  def view_profile?
    super(record)
  end

  def send_private_message?
    private_message = MessageThread.new(user: record).tap(&:readonly!)
    user && Pundit.policy!(user, private_message).new?
  end

  def created_by_id
    record.id
  end
end
