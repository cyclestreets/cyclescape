# frozen_string_literal: true

class MessageComponentPolicy < ApplicationPolicy
  def show?
    Pundit.policy!(user, record.thread).show?
  end
end
