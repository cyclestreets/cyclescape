# frozen_string_literal: true

class MessageComponentPolicy < GuestsAllowedPolicy
  def show?
    Pundit.policy!(user, record.thread).show?
  end
end
